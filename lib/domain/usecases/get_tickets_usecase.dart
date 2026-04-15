import '../../data/repositories/ticket_repository.dart';

class GetTicketsUseCase {
  final TicketRepository repository;

  GetTicketsUseCase(this.repository);

  Future<Map<String, dynamic>> call({
    int page = 1,
    int limit = 10,
  }) {
    return repository.getTickets(
      page: page,
      limit: limit,
    );
  }
}
