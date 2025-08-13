import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../blocs/issue/issue_bloc.dart';
import '../../blocs/issue/issue_event.dart';
import '../../blocs/issue/issue_state.dart';
import '../../widgets/issue_card.dart';

class IssuesScreen extends StatefulWidget {
  final String projectId; 
  const IssuesScreen({super.key, required this.projectId});

  @override
  State<IssuesScreen> createState() => _IssuesScreenState();
}

class _IssuesScreenState extends State<IssuesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<IssueBloc>().add(IssueFetchByProjectRequested(widget.projectId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Issues',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold)),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.funnel(PhosphorIconsStyle.bold)),
            onPressed: () {
              // Add filter functionality
            },
          ),
        ],
      ),
      body: BlocBuilder<IssueBloc, IssueState>(
        builder: (context, state) {
          if (state is IssueLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is IssueError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    PhosphorIcons.warning(),
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading issues',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<IssueBloc>().add(IssueFetchByProjectRequested(widget.projectId));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is IssueLoaded) {
            if (state.issues.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      PhosphorIcons.bug(),
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No issues found',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'All caught up! No issues to display.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.issues.length,
              itemBuilder: (context, index) {
                final issue = state.issues[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: IssueCard(
                    issue: issue,
                    onTap: () {
                      // Navigate to issue detail
                      context.go('/issues/${issue.id}');
                    },
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}