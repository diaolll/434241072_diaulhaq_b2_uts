import '../../data/repositories/ticket_repository.dart';
import '../../data/models/ticket_model.dart';

class CreateTicketUseCase {
  final TicketRepository repository;

  CreateTicketUseCase(this.repository);

  Future<TicketModel> call({
    required String title,
    required String description,
    String? category,
    String priority = 'medium',
  }) {
    return repository.createTicket(
      title: title,
      description: description,
      category: category,
      priority: priority,
    );
  }
}
