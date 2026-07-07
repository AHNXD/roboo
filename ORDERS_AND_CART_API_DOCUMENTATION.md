# Orders and Cart API Documentation

This document covers the APIs related to cart, checkout, user orders, and admin order management.

## Base URLs

| Area | Base URL |
| :--- | :--- |
| Mobile/App API | `{{host}}/api` |
| Admin API | `{{host}}/api/admin` |

## Required Headers

All cart and order endpoints are protected by Sanctum.

```http
Accept: application/json
Content-Type: application/json
Authorization: Bearer <token>
```

Admin order endpoints require a token that belongs to a user with the `admin` role.

## Standard Response Shape

Success:

```json
{
  "success": true,
  "message": "Action completed successfully",
  "data": {}
}
```

Error:

```json
{
  "success": false,
  "message": "Validation failed",
  "data": {
    "errors": {
      "field": [
        "Error message."
      ]
    }
  }
}
```

## Shared Error States

These states can happen on any protected cart or order endpoint.

### 401 Unauthenticated

Returned when the request has no bearer token, an invalid token, or an expired token.

```json
{
  "success": false,
  "message": "Unauthenticated",
  "data": null
}
```

### 404 Resource Not Found

Returned when a route model or record lookup cannot find the requested resource.

```json
{
  "success": false,
  "message": "Resource not found",
  "data": null
}
```

### 405 Method Not Allowed

Returned when the URL exists but is called with the wrong HTTP method.

```json
{
  "success": false,
  "message": "Method not allowed",
  "data": null
}
```

## Shared Data Models

### Cart Object

```json
{
  "items": [
    {
      "id": 15,
      "product_id": 7,
      "quantity": 2,
      "line_total": 100,
      "product": {
        "id": 7,
        "category_id": 2,
        "name": "Robotics Kit",
        "name_ar": "Robotics Kit AR",
        "description": "Starter robotics kit.",
        "description_ar": "Starter robotics kit AR.",
        "price": "50.00",
        "specifications": {
          "weight": "1kg"
        },
        "specifications_ar": {
          "weight": "1kg AR"
        },
        "created_at": "2026-07-07T10:00:00.000000Z",
        "updated_at": "2026-07-07T10:00:00.000000Z",
        "category": {
          "id": 2,
          "name": "Books",
          "name_ar": "Books AR",
          "created_at": "2026-07-07T10:00:00.000000Z",
          "updated_at": "2026-07-07T10:00:00.000000Z"
        },
        "media_list": [
          {
            "id": 31,
            "collection_name": "images",
            "image_url": "https://example.com/storage/31/product.jpg"
          }
        ],
        "is_favorite": false
      }
    }
  ],
  "summary": {
    "item_count": 2,
    "subtotal": 100
  }
}
```

Notes:
- `summary.item_count` is the sum of all item quantities.
- `summary.subtotal` is calculated from current product prices.
- `line_total` is `product.price * quantity`, rounded to 2 decimals.
- Adding an item that already exists increments the existing quantity.
- Updating an item sets the exact quantity.

### Order Object

```json
{
  "id": 101,
  "user_id": 9,
  "total_price": "150.00",
  "created_at": "2026-07-07T10:20:00.000000Z",
  "updated_at": "2026-07-07T10:20:00.000000Z",
  "items": [
    {
      "id": 205,
      "order_id": 101,
      "product_id": 7,
      "quantity": 2,
      "unit_price": "50.00",
      "created_at": "2026-07-07T10:20:00.000000Z",
      "updated_at": "2026-07-07T10:20:00.000000Z",
      "product": {
        "id": 7,
        "category_id": 2,
        "name": "Robotics Kit",
        "name_ar": "Robotics Kit AR",
        "description": "Starter robotics kit.",
        "description_ar": "Starter robotics kit AR.",
        "price": "50.00",
        "specifications": {
          "weight": "1kg"
        },
        "specifications_ar": {
          "weight": "1kg AR"
        },
        "created_at": "2026-07-07T10:00:00.000000Z",
        "updated_at": "2026-07-07T10:00:00.000000Z",
        "media_list": [
          {
            "id": 31,
            "image_url": "https://example.com/storage/31/product.jpg"
          }
        ]
      }
    }
  ]
}
```

Notes:
- `total_price` and `unit_price` are saved as decimal strings.
- Checkout always uses the current product prices from the database.
- A successful checkout deletes all cart items for the user.
- Checkout dispatches order confirmation and admin notification jobs.

## Mobile/App Cart APIs

### 1. Get Cart

Returns the authenticated user's cart.

```http
GET /api/cart
```

#### Request Body

No body.

#### Success Response

Status: `200 OK`

```json
{
  "success": true,
  "message": "Cart retrieved successfully",
  "data": {
    "items": [
      {
        "id": 15,
        "product_id": 7,
        "quantity": 2,
        "line_total": 100,
        "product": {
          "id": 7,
          "category_id": 2,
          "name": "Robotics Kit",
          "name_ar": "Robotics Kit AR",
          "description": "Starter robotics kit.",
          "description_ar": "Starter robotics kit AR.",
          "price": "50.00",
          "specifications": {
            "weight": "1kg"
          },
          "specifications_ar": {
            "weight": "1kg AR"
          },
          "created_at": "2026-07-07T10:00:00.000000Z",
          "updated_at": "2026-07-07T10:00:00.000000Z",
          "category": {
            "id": 2,
            "name": "Books",
            "name_ar": "Books AR",
            "created_at": "2026-07-07T10:00:00.000000Z",
            "updated_at": "2026-07-07T10:00:00.000000Z"
          },
          "media_list": [],
          "is_favorite": false
        }
      }
    ],
    "summary": {
      "item_count": 2,
      "subtotal": 100
    }
  }
}
```

#### Empty Cart Response

Status: `200 OK`

```json
{
  "success": true,
  "message": "Cart retrieved successfully",
  "data": {
    "items": [],
    "summary": {
      "item_count": 0,
      "subtotal": 0
    }
  }
}
```

#### Error States

| Status | Case |
| :--- | :--- |
| `401` | Missing or invalid user token |

### 2. Add Item to Cart

Adds a product to the cart. If the product is already in the cart, the quantity is incremented.

```http
POST /api/cart/items
```

#### Request Body

| Field | Type | Required | Rules | Description |
| :--- | :--- | :--- | :--- | :--- |
| `product_id` | integer | Yes | Must exist in `products.id` | Product to add |
| `quantity` | integer | Yes | Minimum `1` | Quantity to add |

Example:

```json
{
  "product_id": 7,
  "quantity": 2
}
```

#### Success Response

Status: `200 OK`

```json
{
  "success": true,
  "message": "Item added to cart successfully",
  "data": {
    "items": [
      {
        "id": 15,
        "product_id": 7,
        "quantity": 2,
        "line_total": 100,
        "product": {
          "id": 7,
          "name": "Robotics Kit",
          "name_ar": "Robotics Kit AR",
          "price": "50.00",
          "media_list": [],
          "is_favorite": false
        }
      }
    ],
    "summary": {
      "item_count": 2,
      "subtotal": 100
    }
  }
}
```

#### Existing Item Increment Response

If the user already has product `7` with quantity `2`, sending quantity `1` changes the quantity to `3`.

Status: `200 OK`

```json
{
  "success": true,
  "message": "Item added to cart successfully",
  "data": {
    "items": [
      {
        "id": 15,
        "product_id": 7,
        "quantity": 3,
        "line_total": 150,
        "product": {
          "id": 7,
          "name": "Robotics Kit",
          "name_ar": "Robotics Kit AR",
          "price": "50.00",
          "media_list": [],
          "is_favorite": false
        }
      }
    ],
    "summary": {
      "item_count": 3,
      "subtotal": 150
    }
  }
}
```

#### Validation Error Response

Status: `422 Unprocessable Entity`

```json
{
  "success": false,
  "message": "Validation failed",
  "data": {
    "errors": {
      "product_id": [
        "The selected product id is invalid."
      ],
      "quantity": [
        "The quantity field must be at least 1."
      ]
    }
  }
}
```

#### Error States

| Status | Case |
| :--- | :--- |
| `401` | Missing or invalid user token |
| `422` | Missing `product_id`, product does not exist, missing `quantity`, or `quantity < 1` |

### 3. Update Cart Item Quantity

Sets the exact quantity for an existing cart line.

```http
POST /api/cart/items/update
```

#### Request Body

| Field | Type | Required | Rules | Description |
| :--- | :--- | :--- | :--- | :--- |
| `product_id` | integer | Yes | Must exist in `products.id` | Existing product line |
| `quantity` | integer | Yes | Minimum `1` | New quantity |

Example:

```json
{
  "product_id": 7,
  "quantity": 5
}
```

#### Success Response

Status: `200 OK`

```json
{
  "success": true,
  "message": "Cart item updated successfully",
  "data": {
    "items": [
      {
        "id": 15,
        "product_id": 7,
        "quantity": 5,
        "line_total": 250,
        "product": {
          "id": 7,
          "name": "Robotics Kit",
          "name_ar": "Robotics Kit AR",
          "price": "50.00",
          "media_list": [],
          "is_favorite": false
        }
      }
    ],
    "summary": {
      "item_count": 5,
      "subtotal": 250
    }
  }
}
```

#### Cart Line Not Found Response

Returned when the product exists, but it is not currently in this user's cart.

Status: `422 Unprocessable Entity`

```json
{
  "success": false,
  "message": "Validation failed",
  "data": {
    "errors": {
      "product_id": [
        "Cart item not found."
      ]
    }
  }
}
```

#### Validation Error Response

Status: `422 Unprocessable Entity`

```json
{
  "success": false,
  "message": "Validation failed",
  "data": {
    "errors": {
      "quantity": [
        "The quantity field must be at least 1."
      ]
    }
  }
}
```

#### Error States

| Status | Case |
| :--- | :--- |
| `401` | Missing or invalid user token |
| `422` | Missing `product_id`, product does not exist, missing `quantity`, `quantity < 1`, or cart line does not exist |

### 4. Remove Cart Item

Removes one product line from the authenticated user's cart.

```http
POST /api/cart/items/remove
```

#### Request Body

| Field | Type | Required | Rules | Description |
| :--- | :--- | :--- | :--- | :--- |
| `product_id` | integer | Yes | Must exist in `products.id` | Product line to remove |

Example:

```json
{
  "product_id": 7
}
```

#### Success Response

Status: `200 OK`

```json
{
  "success": true,
  "message": "Item removed from cart successfully",
  "data": {
    "items": [],
    "summary": {
      "item_count": 0,
      "subtotal": 0
    }
  }
}
```

#### Cart Line Not Found Response

Status: `422 Unprocessable Entity`

```json
{
  "success": false,
  "message": "Validation failed",
  "data": {
    "errors": {
      "product_id": [
        "Cart item not found."
      ]
    }
  }
}
```

#### Validation Error Response

Status: `422 Unprocessable Entity`

```json
{
  "success": false,
  "message": "Validation failed",
  "data": {
    "errors": {
      "product_id": [
        "The product id field is required."
      ]
    }
  }
}
```

#### Error States

| Status | Case |
| :--- | :--- |
| `401` | Missing or invalid user token |
| `422` | Missing `product_id`, product does not exist, or cart line does not exist |

### 5. Clear Cart

Removes all items from the authenticated user's cart.

```http
POST /api/cart/clear
```

#### Request Body

No body. Send `{}` or an empty request body.

#### Success Response

Status: `200 OK`

```json
{
  "success": true,
  "message": "Cart cleared successfully",
  "data": {
    "items": [],
    "summary": {
      "item_count": 0,
      "subtotal": 0
    }
  }
}
```

#### Already Empty Cart Response

The endpoint is idempotent for an empty cart.

Status: `200 OK`

```json
{
  "success": true,
  "message": "Cart cleared successfully",
  "data": {
    "items": [],
    "summary": {
      "item_count": 0,
      "subtotal": 0
    }
  }
}
```

#### Error States

| Status | Case |
| :--- | :--- |
| `401` | Missing or invalid user token |

## Mobile/App Order APIs

### 1. Checkout: Create Order From Cart

Creates an order from the authenticated user's current cart.

```http
POST /api/orders
```

Important behavior:
- The request body is empty.
- Do not send an `items` array.
- Product prices are read from the database during checkout.
- The cart is cleared after successful checkout.
- Email and admin notification jobs are dispatched after checkout.

#### Request Body

No body. Send `{}` or an empty request body.

#### Success Response

Status: `201 Created`

```json
{
  "success": true,
  "message": "Order placed successfully",
  "data": {
    "id": 101,
    "user_id": 9,
    "total_price": "150.00",
    "created_at": "2026-07-07T10:20:00.000000Z",
    "updated_at": "2026-07-07T10:20:00.000000Z",
    "items": [
      {
        "id": 205,
        "order_id": 101,
        "product_id": 7,
        "quantity": 1,
        "unit_price": "50.00",
        "created_at": "2026-07-07T10:20:00.000000Z",
        "updated_at": "2026-07-07T10:20:00.000000Z",
        "product": {
          "id": 7,
          "category_id": 2,
          "name": "Robotics Kit",
          "name_ar": "Robotics Kit AR",
          "description": "Starter robotics kit.",
          "description_ar": "Starter robotics kit AR.",
          "price": "50.00",
          "specifications": {
            "weight": "1kg"
          },
          "specifications_ar": {
            "weight": "1kg AR"
          },
          "created_at": "2026-07-07T10:00:00.000000Z",
          "updated_at": "2026-07-07T10:00:00.000000Z"
        }
      },
      {
        "id": 206,
        "order_id": 101,
        "product_id": 8,
        "quantity": 1,
        "unit_price": "100.00",
        "created_at": "2026-07-07T10:20:00.000000Z",
        "updated_at": "2026-07-07T10:20:00.000000Z",
        "product": {
          "id": 8,
          "category_id": 2,
          "name": "Advanced Robotics Kit",
          "name_ar": "Advanced Robotics Kit AR",
          "description": "Advanced robotics kit.",
          "description_ar": "Advanced Robotics Kit AR.",
          "price": "100.00",
          "specifications": {
            "weight": "2kg"
          },
          "specifications_ar": {
            "weight": "2kg AR"
          },
          "created_at": "2026-07-07T10:00:00.000000Z",
          "updated_at": "2026-07-07T10:00:00.000000Z"
        }
      }
    ],
    "user": {
      "id": 9,
      "name": "Ahmed Ali",
      "email": "ahmed@example.com",
      "created_at": "2026-07-07T09:00:00.000000Z",
      "updated_at": "2026-07-07T09:00:00.000000Z"
    }
  }
}
```

#### Empty Cart Response

Status: `422 Unprocessable Entity`

```json
{
  "success": false,
  "message": "Validation failed",
  "data": {
    "errors": {
      "cart": [
        "Your cart is empty."
      ]
    }
  }
}
```

#### Product Deleted Before Checkout Response

Returned if one or more products in the cart no longer exist.

Status: `422 Unprocessable Entity`

```json
{
  "success": false,
  "message": "Validation failed",
  "data": {
    "errors": {
      "cart": [
        "One or more products in your cart are no longer available."
      ]
    }
  }
}
```

#### Error States

| Status | Case |
| :--- | :--- |
| `401` | Missing or invalid user token |
| `422` | Cart is empty or cart contains unavailable products |

### 2. List My Orders

Returns paginated order history for the authenticated user.

```http
GET /api/orders
```

#### Query Parameters

The controller uses Laravel pagination defaults. `page` is supported by Laravel pagination.

| Parameter | Type | Required | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `page` | integer | No | `1` | Page number |

#### Request Body

No body.

#### Success Response

Status: `200 OK`

```json
{
  "success": true,
  "message": "Order history retrieved successfully",
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 101,
        "user_id": 9,
        "total_price": "150.00",
        "created_at": "2026-07-07T10:20:00.000000Z",
        "updated_at": "2026-07-07T10:20:00.000000Z",
        "items": [
          {
            "id": 205,
            "order_id": 101,
            "product_id": 7,
            "quantity": 1,
            "unit_price": "50.00",
            "product": {
              "id": 7,
              "name": "Robotics Kit",
              "name_ar": "Robotics Kit AR",
              "price": "50.00",
              "media_list": [
                {
                  "id": 31,
                  "image_url": "https://example.com/storage/31/product.jpg"
                }
              ]
            }
          }
        ]
      }
    ],
    "first_page_url": "https://example.com/api/orders?page=1",
    "from": 1,
    "last_page": 1,
    "last_page_url": "https://example.com/api/orders?page=1",
    "links": [],
    "next_page_url": null,
    "path": "https://example.com/api/orders",
    "per_page": 25,
    "prev_page_url": null,
    "to": 1,
    "total": 1
  }
}
```

#### Empty History Response

Status: `200 OK`

```json
{
  "success": true,
  "message": "Order history retrieved successfully",
  "data": {
    "current_page": 1,
    "data": [],
    "first_page_url": "https://example.com/api/orders?page=1",
    "from": null,
    "last_page": 1,
    "last_page_url": "https://example.com/api/orders?page=1",
    "links": [],
    "next_page_url": null,
    "path": "https://example.com/api/orders",
    "per_page": 25,
    "prev_page_url": null,
    "to": null,
    "total": 0
  }
}
```

#### Error States

| Status | Case |
| :--- | :--- |
| `401` | Missing or invalid user token |

### 3. Get My Order Details

Returns one order by ID if it belongs to the authenticated user.

```http
GET /api/orders/{id}
```

#### Path Parameters

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `id` | integer | Yes | Order ID |

#### Request Body

No body.

#### Success Response

Status: `200 OK`

```json
{
  "success": true,
  "message": "Order details retrieved successfully",
  "data": {
    "id": 101,
    "user_id": 9,
    "total_price": "150.00",
    "created_at": "2026-07-07T10:20:00.000000Z",
    "updated_at": "2026-07-07T10:20:00.000000Z",
    "items": [
      {
        "id": 205,
        "order_id": 101,
        "product_id": 7,
        "quantity": 1,
        "unit_price": "50.00",
        "created_at": "2026-07-07T10:20:00.000000Z",
        "updated_at": "2026-07-07T10:20:00.000000Z",
        "product": {
          "id": 7,
          "name": "Robotics Kit",
          "name_ar": "Robotics Kit AR",
          "price": "50.00",
          "media_list": [
            {
              "id": 31,
              "image_url": "https://example.com/storage/31/product.jpg"
            }
          ]
        }
      }
    ],
    "user": {
      "id": 9,
      "name": "Ahmed Ali",
      "email": "ahmed@example.com"
    }
  }
}
```

#### Another User's Order Response

Status: `403 Forbidden`

```json
{
  "success": false,
  "message": "Unauthorized",
  "data": []
}
```

#### Order Not Found Response

Status: `404 Not Found`

```json
{
  "success": false,
  "message": "Resource not found",
  "data": null
}
```

#### Error States

| Status | Case |
| :--- | :--- |
| `401` | Missing or invalid user token |
| `403` | Order exists but belongs to another user |
| `404` | Order ID does not exist |

## Admin Order APIs

There are no admin cart endpoints in the current codebase. Admin users can list, view, and delete orders.

### 1. List Orders

Returns paginated orders for the admin dashboard.

```http
GET /api/admin/orders
```

#### Query Parameters

| Parameter | Type | Required | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `page` | integer | No | `1` | Page number |
| `perPage` | integer | No | `25` | Items per page. Minimum `1`, maximum `100` |
| `search` | string | No | None | Search by user `name`, user `email`, or exact numeric order ID |

#### Request Body

No body.

#### Success Response

Status: `200 OK`

```json
{
  "success": true,
  "message": "Orders retrieved successfully",
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 101,
        "user_id": 9,
        "total_price": "150.00",
        "created_at": "2026-07-07T10:20:00.000000Z",
        "updated_at": "2026-07-07T10:20:00.000000Z",
        "user": {
          "id": 9,
          "name": "Ahmed Ali",
          "email": "ahmed@example.com"
        },
        "items": [
          {
            "id": 205,
            "order_id": 101,
            "product_id": 7,
            "quantity": 1,
            "unit_price": "50.00",
            "product": {
              "id": 7,
              "name": "Robotics Kit",
              "name_ar": "Robotics Kit AR",
              "price": "50.00"
            }
          }
        ]
      }
    ],
    "first_page_url": "https://example.com/api/admin/orders?page=1",
    "from": 1,
    "last_page": 1,
    "last_page_url": "https://example.com/api/admin/orders?page=1",
    "links": [],
    "next_page_url": null,
    "path": "https://example.com/api/admin/orders",
    "per_page": 25,
    "prev_page_url": null,
    "to": 1,
    "total": 1
  }
}
```

#### Search Example

```http
GET /api/admin/orders?search=ahmed&perPage=10&page=1
```

Status: `200 OK`

```json
{
  "success": true,
  "message": "Orders retrieved successfully",
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 101,
        "user_id": 9,
        "total_price": "150.00",
        "user": {
          "id": 9,
          "name": "Ahmed Ali",
          "email": "ahmed@example.com"
        },
        "items": []
      }
    ],
    "per_page": 10,
    "total": 1
  }
}
```

#### Empty List Response

Status: `200 OK`

```json
{
  "success": true,
  "message": "Orders retrieved successfully",
  "data": {
    "current_page": 1,
    "data": [],
    "from": null,
    "last_page": 1,
    "per_page": 25,
    "to": null,
    "total": 0
  }
}
```

#### Error States

| Status | Case |
| :--- | :--- |
| `401` | Missing or invalid token |
| `403` | Authenticated user is not an admin |

### 2. Get Order Details

Returns a single order for admin review.

```http
GET /api/admin/orders/{id}
```

#### Path Parameters

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `id` | integer | Yes | Order ID |

#### Request Body

No body.

#### Success Response

Status: `200 OK`

```json
{
  "success": true,
  "message": "Order details retrieved successfully",
  "data": {
    "id": 101,
    "user_id": 9,
    "total_price": "150.00",
    "created_at": "2026-07-07T10:20:00.000000Z",
    "updated_at": "2026-07-07T10:20:00.000000Z",
    "user": {
      "id": 9,
      "name": "Ahmed Ali",
      "email": "ahmed@example.com"
    },
    "items": [
      {
        "id": 205,
        "order_id": 101,
        "product_id": 7,
        "quantity": 1,
        "unit_price": "50.00",
        "created_at": "2026-07-07T10:20:00.000000Z",
        "updated_at": "2026-07-07T10:20:00.000000Z",
        "product": {
          "id": 7,
          "category_id": 2,
          "name": "Robotics Kit",
          "name_ar": "Robotics Kit AR",
          "description": "Starter robotics kit.",
          "description_ar": "Starter robotics kit AR.",
          "price": "50.00",
          "specifications": {
            "weight": "1kg"
          },
          "specifications_ar": {
            "weight": "1kg AR"
          },
          "created_at": "2026-07-07T10:00:00.000000Z",
          "updated_at": "2026-07-07T10:00:00.000000Z",
          "media_list": [
            {
              "id": 31,
              "image_url": "https://example.com/storage/31/product.jpg"
            }
          ]
        }
      }
    ]
  }
}
```

#### Order Not Found Response

Status: `404 Not Found`

```json
{
  "success": false,
  "message": "Resource not found",
  "data": null
}
```

#### Error States

| Status | Case |
| :--- | :--- |
| `401` | Missing or invalid token |
| `403` | Authenticated user is not an admin |
| `404` | Order ID does not exist |

### 3. Delete Order

Deletes an order and its order items. Order items are removed by database cascade.

```http
DELETE /api/admin/orders/{id}
```

#### Path Parameters

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `id` | integer | Yes | Order ID |

#### Request Body

No body.

#### Success Response

Status: `200 OK`

```json
{
  "success": true,
  "message": "Order deleted successfully",
  "data": null
}
```

#### Order Not Found Response

Status: `404 Not Found`

```json
{
  "success": false,
  "message": "Resource not found",
  "data": null
}
```

#### Error States

| Status | Case |
| :--- | :--- |
| `401` | Missing or invalid token |
| `403` | Authenticated user is not an admin |
| `404` | Order ID does not exist |

## End-to-End Checkout Example

### Step 1: Add products to cart

```http
POST /api/cart/items
```

```json
{
  "product_id": 7,
  "quantity": 2
}
```

### Step 2: Review cart

```http
GET /api/cart
```

Expected summary:

```json
{
  "item_count": 2,
  "subtotal": 100
}
```

### Step 3: Checkout

```http
POST /api/orders
```

Body:

```json
{}
```

Expected response:

```json
{
  "success": true,
  "message": "Order placed successfully",
  "data": {
    "id": 101,
    "total_price": "100.00",
    "items": [
      {
        "product_id": 7,
        "quantity": 2,
        "unit_price": "50.00"
      }
    ]
  }
}
```

### Step 4: Confirm cart is empty

```http
GET /api/cart
```

Expected response:

```json
{
  "success": true,
  "message": "Cart retrieved successfully",
  "data": {
    "items": [],
    "summary": {
      "item_count": 0,
      "subtotal": 0
    }
  }
}
```

## Implementation Notes for Frontend Developers

- Use `POST /api/cart/items` for an "add to cart" button.
- Use `POST /api/cart/items/update` for quantity steppers in the cart screen.
- Use `POST /api/cart/items/remove` to remove one product line.
- Use `POST /api/cart/clear` to empty the whole cart.
- Use `POST /api/orders` with an empty body for checkout.
- Do not calculate order totals on the client as the source of truth. Display client totals only as a preview.
- After successful checkout, refresh cart state because the backend clears it.
- Handle `422 data.errors.cart[0]` on checkout to prevent double-submit or empty-cart checkout messages.
- Handle `403` on `GET /api/orders/{id}` as "this order does not belong to the current user."
