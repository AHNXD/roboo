import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/services_locater.dart';
import 'package:roboo/core/widgets/status_display_widget.dart';
import 'package:roboo/features/app/courses/presentation/view/widgets/courses_filter_tabs_widget.dart';
import 'package:roboo/features/app/quizes/data/models/quiz_model.dart';
import 'package:roboo/features/app/quizes/presentation/view-model/quizzes_cubit/quizzes_cubit.dart';
import 'package:roboo/features/app/quizes/presentation/view/quiz_entry.dart';
import 'package:roboo/features/app/quizes/presentation/view/widgets/quize_list_item_widget.dart';
import 'package:roboo/features/shared/topics/data/models/topic_model.dart';

class QuizesScreen extends StatelessWidget {
  static const String routeName = '/quizes';

  const QuizesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuizzesCubit(getit.get(), getit.get())..getQuizzesData(),
      child: Scaffold(
        appBar: CustomAppbar(title: "quizzes_title".tr(context)),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Expanded(
                child: BlocBuilder<QuizzesCubit, QuizzesState>(
                  builder: (context, state) {
                    return switch (state) {
                      QuizzesInitial() ||
                      QuizzesLoading() => StatusDisplayWidget(
                        message: "wait".tr(context),
                        withAnimation: true,
                      ),
                      QuizzesError(:final errorMsg) => StatusDisplayWidget(
                        message: errorMsg.tr(context),
                      ),
                      QuizzesEmpty(:final topics, :final selectedIndex) =>
                        _QuizzesContent(
                          selectedFilterIndex: selectedIndex,
                          filters: _topicFilters(context, topics),
                          quizzes: const [],
                        ),
                      QuizzesLoaded(
                        :final topics,
                        :final quizzes,
                        :final selectedIndex,
                      ) =>
                        _QuizzesContent(
                          selectedFilterIndex: selectedIndex,
                          filters: _topicFilters(context, topics),
                          quizzes: quizzes,
                        ),
                    };
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _topicFilters(
    BuildContext context,
    List<TopicModel> topics,
  ) {
    final languageCode = Localizations.localeOf(context).languageCode;

    return [
      {'label': 'all_topics', 'translateLabel': true},
      ...topics.map(
        (topic) => {
          'label': topic.nameFor(languageCode),
          'translateLabel': false,
        },
      ),
    ];
  }
}

class _QuizzesContent extends StatelessWidget {
  final int selectedFilterIndex;
  final List<Map<String, dynamic>> filters;
  final List<QuizModel> quizzes;

  const _QuizzesContent({
    required this.selectedFilterIndex,
    required this.filters,
    required this.quizzes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CourseFilterTabs(
          selectedIndex: selectedFilterIndex,
          filters: filters,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          clipBehavior: Clip.none,
          onSelect: context.read<QuizzesCubit>().selectTopic,
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildQuizzesContent(context)),
      ],
    );
  }

  Widget _buildQuizzesContent(BuildContext context) {
    if (quizzes.isEmpty) {
      return StatusDisplayWidget(message: "no_quizzes_available".tr(context));
    }

    final languageCode = Localizations.localeOf(context).languageCode;
    return RefreshIndicator(
      onRefresh: context.read<QuizzesCubit>().getQuizzesData,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: quizzes.length,
        separatorBuilder: (c, i) => const SizedBox(height: 24),
        itemBuilder: (context, index) {
          final quiz = quizzes[index];
          final quizId = quiz.id;

          return QuizListItem(
            title: quiz.titleFor(languageCode),
            questions: quiz.questionsCount,
            duration: quiz.timeLimit,
            points: quiz.points,
            isSolved: quiz.solved,
            // A solved quiz pays out once and the backend refuses a second
            // attempt, so it is not opened at all.
            onTap: () => openQuizIfUnsolved(
              context,
              quizId: quizId,
              isSolved: quiz.solved,
              // `solved` only changes server-side, so the list has to re-fetch
              // to stop offering a quiz that is now done.
              onClosed: context.read<QuizzesCubit>().getQuizzesData,
            ),
          );
        },
      ),
    );
  }
}
