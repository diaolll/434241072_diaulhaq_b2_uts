import '../../data/repositories/ticket_repository.dart';
import '../../data/models/ticket_model.dart';

class CreateTicketUseCase {
  final TicketRepositoryImpl repository;

  CreateTicketUseCase(this.repository);

  Future<TicketModel> call({
    required String title,
    required String description,
    required String category,
    String? priority,
    String? location,
    List<String>? attachments,
  }) {
    return repository.createTicket(
      title: title,
      description: description,
      category: category,
      priority: priority,
      location: location,
      attachments: attachments,
    );
  }
}
