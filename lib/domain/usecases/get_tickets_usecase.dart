import '../../data/repositories/ticket_repository.dart';
import '../../data/models/ticket_model.dart';

class GetTicketsUseCase {
  final TicketRepository repository;

  GetTicketsUseCase(this.repository);

  Future<List<TicketModel>> call() {
    return repository.getTickets();
  }
}
