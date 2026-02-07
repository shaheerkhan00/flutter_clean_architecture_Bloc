import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sitelog/features/daily_reports/domain/entities/site_event.dart';
import '../bloc/daily_report_bloc.dart';
import '../bloc/daily_report_event.dart';
import '../bloc/daily_report_state.dart';
import '../../../../injection_container.dart';
import 'package:uuid/uuid.dart';

class DailyReportPage extends StatelessWidget {
  final String siteId;
  const DailyReportPage({Key? key, required this.siteId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DailyReportBloc>()..add(LoadEvents(siteId)),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Daily Report'),
              actions: [
                IconButton(
                  onPressed: () => context.read<DailyReportBloc>().add(
                    const SyncReportsEvent(),
                  ),
                  icon: Icon(Icons.sync),
                ),
              ],
            ),
            body: BlocListener<DailyReportBloc, DailyReportState>(
              listener: (context, state) {
                if (state is DailyReportLoaded && state.uiMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.uiMessage!),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },

              child: BlocBuilder<DailyReportBloc, DailyReportState>(
                builder: (context, state) {
                  // State 1: Loading
                  if (state is DailyReportLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // State 2: Loaded (Success)
                  else if (state is DailyReportLoaded) {
                    if (state.events.isEmpty) {
                      return const Center(
                        child: Text("No events yet. Click + to start."),
                      );
                    }

                    // The List
                    return ListView.builder(
                      itemCount: state.events.length,
                      itemBuilder: (context, index) {
                        final event = state.events[index];
                        return Dismissible(
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          key: Key(event.eventId),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            context.read<DailyReportBloc>().add(
                              DeleteEvent(event.eventId),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Event deleted')),
                            );
                          },

                          child: Card(
                            margin: const EdgeInsets.all(8.0),
                            child: ListTile(
                              leading: Icon(
                                event is LaborEvent
                                    ? Icons.group
                                    : Icons.warning,
                                color: event is LaborEvent
                                    ? Colors.blue
                                    : Colors.orange,
                              ),

                              title: Text(event.description),
                              subtitle: Text(
                                event is LaborEvent
                                    ? 'Workers: ${event.workerCount}'
                                    : 'Severity: ${(event as SafetyIncident).severity}'
                                          .split('.')
                                          .last,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize
                                    .min, // <--- This keeps the Row tight to the right
                                children: [
                                  // 1. The Timestamp (Your existing code)
                                  Text(
                                    '${event.timestamp.hour}:${event.timestamp.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),

                                  // 2. Small Gap
                                  const SizedBox(width: 8),

                                  // 3. The Sync Icon (New!)
                                  Icon(
                                    event.isSynced
                                        ? Icons.cloud_done
                                        : Icons.cloud_off,
                                    color: event.isSynced
                                        ? Colors.green
                                        : Colors.grey,
                                    size: 16, // Keep it subtle
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  // State 3: Error
                  else if (state is DailyReportError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  // State 4: Initial (Should be fast, but just in case)
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                print('Fab pressed');
                final bloc = context.read<DailyReportBloc>();
                _showDialog(context, siteId, bloc);
              },
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}

void _showDialog(BuildContext context, String siteId, DailyReportBloc bloc) {
  final descriptionController = TextEditingController();
  final workerCountController = TextEditingController();
  String type = 'labor';
  Severity severity = Severity.low;

  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Site Event'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text('Event Type: '),
                      DropdownButton<String>(
                        value: type,
                        items: const [
                          DropdownMenuItem(
                            value: 'labor',
                            child: Text('Labor Event'),
                          ),

                          DropdownMenuItem(
                            value: 'safety',
                            child: Text('Safety Event'),
                          ),
                        ],
                        onChanged: (val) => setState(() {
                          type = val!;
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 10),
                  if (type == 'labor')
                    TextField(
                      controller: workerCountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Worker Count: ',
                      ),
                    )
                  else if (type == 'safety')
                    DropdownButton<Severity>(
                      value: severity,
                      items: Severity.values.map((s) {
                        return DropdownMenuItem(
                          value: s,
                          child: Text(s.toString().split('.').last),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => severity = val!),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  saveToDb(
                    bloc: bloc,
                    context: context,
                    siteId: siteId,
                    type: type,
                    workerController: workerCountController,
                    descriptionController: descriptionController,
                    severity: severity,
                  );
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
    },
  );
}

void saveToDb({
  required BuildContext context,
  required DailyReportBloc bloc,
  required String siteId,
  required String type,
  required TextEditingController workerController,
  required TextEditingController descriptionController,

  required Severity? severity,
}) {
  final newEvent;
  final id = const Uuid().v4();
  final now = DateTime.now();
  if (type == 'labor') {
    newEvent = LaborEvent(
      eventId: id,
      siteId: siteId,
      timestamp: now,
      description: descriptionController.text,
      workerCount: int.tryParse(workerController.text) ?? 0,
    );
  } else {
    newEvent = SafetyIncident(
      eventId: id,
      siteId: siteId,
      timestamp: now,
      description: descriptionController.text,
      severity: severity!,
    );
  }
  bloc.add(AddEvent(newEvent));
  Navigator.pop(context);
}
