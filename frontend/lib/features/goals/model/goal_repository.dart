import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../model/goal_model.dart';

class GoalRepository {
  final Dio _dio = DioClient.instance;

  // ============================================================
  // GET ALL GOALS
  // ============================================================

  Future<List<GoalModel>> getGoals() async {
    final response = await _dio.get('/api/goal/');

    final responseData = response.data as Map<String, dynamic>;

    final data = responseData['data'] as List<dynamic>;

    return data
        .map((item) => GoalModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // ============================================================
  // GET SINGLE GOAL
  // ============================================================

  Future<GoalModel> getGoal(int id) async {
    final response = await _dio.get('/api/goal/$id');

    final responseData = response.data as Map<String, dynamic>;

    return GoalModel.fromJson(responseData['data'] as Map<String, dynamic>);
  }

  // ============================================================
  // CREATE GOAL
  // ============================================================
  //
  // IMPORTANT:
  // Creating a goal does NOT directly set current_amount.
  //
  // If the user wants to start with money, that money is represented
  // as a Saving record through initial_saving_amount on the backend.
  //
  // For now CreateGoalSheet sends 0.
  // ============================================================

  Future<GoalModel> createGoal({
    required String title,
    required double targetAmount,
    required DateTime targetDate,
    String? description,
  }) async {
    final response = await _dio.post(
      '/api/goal/',
      data: {
        'title': title,
        'target_amount': targetAmount,
        'initial_saving_amount': 0,
        'target_date': targetDate.toIso8601String().split('T').first,
        'description': description,
      },
    );

    final responseData = response.data as Map<String, dynamic>;

    final id = (responseData['data']['id'] as num).toInt();

    return GoalModel(
      id: id,
      title: title,
      targetAmount: targetAmount,
      currentAmount: 0,
      targetDate: targetDate,
      description: description,
    );
  }
  // ============================================================
  // UPDATE GOAL
  // ============================================================

  Future<void> updateGoal(
    int id, {
    String? title,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    String? description,
  }) async {
    final Map<String, dynamic> data = {};

    if (title != null) {
      data['title'] = title;
    }

    if (targetAmount != null) {
      data['target_amount'] = targetAmount;
    }

    if (currentAmount != null) {
      data['current_amount'] = currentAmount;
    }

    if (targetDate != null) {
      data['target_date'] = targetDate.toIso8601String().split('T').first;
    }

    if (description != null) {
      data['description'] = description;
    }

    await _dio.put('/api/goal/$id', data: data);
  }

  // ============================================================
  // DELETE GOAL
  // ============================================================

  Future<void> deleteGoal(int id) async {
    await _dio.delete('/api/goal/$id');
  }
}
