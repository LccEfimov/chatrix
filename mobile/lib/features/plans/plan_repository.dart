import '../../api/api_client.dart';
import 'plan_models.dart';

abstract class PlanRepository {
  Future<List<Plan>> fetchPlans();
  Future<Subscription> fetchSubscription();
  Future<Subscription> activatePlan(String planCode);
}

class ApiPlanRepository implements PlanRepository {
  ApiPlanRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<Plan>> fetchPlans() async {
    final response = await _client.dio.get<List<dynamic>>('/plans');
    return response.data!
        .map((item) => Plan.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Subscription> fetchSubscription() async {
    final response = await _client.dio.get<Map<String, dynamic>>('/subscriptions/me');
    return Subscription.fromJson(response.data!);
  }

  @override
  Future<Subscription> activatePlan(String planCode) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      '/subscriptions/activate',
      data: {'plan_code': planCode},
    );
    return Subscription.fromJson(response.data!);
  }
}
