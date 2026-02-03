import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sitelog/features/daily_reports/presentation/bloc/daily_report_bloc.dart';
import 'package:sitelog/features/daily_reports/presentation/bloc/daily_report_state.dart';

Widget buildBlocListBuilder(BuildContext context, DailyReportState state) {
  return BlocBuilder<DailyReportBloc, DailyReportState>(
    builder: (context, state) {
      if (state is DailyReportLoading) {
        return const Center(child: CircularProgressIndicator());
      } else if (state is DailyReportError) {
        return Center(child: Text('Error: ${state.message}'));
      } else if (state is DailyReportLoaded) {
        return ListView.builder(
          itemCount: state.events.length,
          itemBuilder: (context, index) {
            final event = state.events[index];
            return ListTile(
              title: Text(event.description),
              subtitle: Text(event.timestamp.toString()),
              trailing: IconButton(
                onPressed: () {
                  print('Delete event pressed');
                },
                icon: Icon(Icons.delete),
              ),
            );
          },
        );
      }
      return const Center(child: Text('No data available'));
    },
  );
}
