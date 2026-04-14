import '../../data/repositories/ticket_repository.dart';
import '../../data/models/ticket_model.dart';

class GetTicketsUseCase {
  final TicketRepositoryImpl repository;

  GetTicketsUseCase(this.repository);

  Future<List<TicketModel>> call({
    int page = 1,
    int limit = 10,
    String? status,
    String? category,
    String? priority,
  }) {
    return repository.getTickets(
      page: page,
      limit: limit,
      status: status,
      category: category,
      priority: priority,
    );
  }
}
