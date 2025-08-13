import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../blocs/project/project_bloc.dart';
import '../../blocs/project/project_event.dart';
import '../../blocs/project/project_state.dart';
import '../../widgets/project_card.dart';
import '../../models/project.dart';
import '../../services/rbac_service.dart';
import '../../services/api_service.dart';
import '../../mixins/rbac_mixin.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> with RBACMixin<ProjectsScreen> {
  bool _canManageProjects = false;
  @override
  void initState() {
    super.initState();
    context.read<ProjectBloc>().add(ProjectFetchRequested());
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    final canManageProjects = await rbacService.canManageProjects();
    if (mounted) {
      setState(() {
        _canManageProjects = canManageProjects;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Projects',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold)),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          if (_canManageProjects)
            IconButton(
              icon: Icon(PhosphorIcons.plus(PhosphorIconsStyle.bold)),
              onPressed: () => context.go('/projects/create'),
            ),
        ],
      ),
      body: BlocConsumer<ProjectBloc, ProjectState>(
        listener: (context, state) {
          if (state is ProjectCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Project created successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
            // Refresh projects list
            context.read<ProjectBloc>().add(ProjectFetchRequested());
          } else if (state is ProjectUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Project updated successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
            // Refresh projects list
            context.read<ProjectBloc>().add(ProjectFetchRequested());
          } else if (state is ProjectDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Project deleted successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
            // Refresh projects list
            context.read<ProjectBloc>().add(ProjectFetchRequested());
          }
        },
        builder: (context, state) {
          if (state is ProjectLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProjectError) {
                  print("---------------------${state.message}---------------");
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
                    'Error loading projects',
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
                      context.read<ProjectBloc>().add(ProjectFetchRequested());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is ProjectLoaded) {
            if (state.projects.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      PhosphorIcons.folder(),
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _canManageProjects ? 'No projects yet' : 'No projects available',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _canManageProjects 
                          ? 'Create your first project to get started'
                          : 'You are not a member of any projects yet. Contact an administrator to be added to a project.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    if (_canManageProjects) ...[  
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => context.go('/projects/create'),
                        icon: Icon(PhosphorIcons.plus()),
                        label: const Text('Create Project'),
                      ),
                    ],
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.projects.length,
              itemBuilder: (context, index) {
                final project = state.projects[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ProjectCard(
                    project: project,
                    onTap: () => context.go('/projects/${project.id}'),
                    onEdit: _canManageProjects 
                        ? () => context.go('/projects/${project.id}/edit')
                        : null,
                    onDelete: _canManageProjects 
                        ? () => _showDeleteDialog(context, project)
                        : null,
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: _canManageProjects
          ? FloatingActionButton.extended(
              onPressed: () => context.go('/projects/create'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              icon: Icon(PhosphorIcons.plus(PhosphorIconsStyle.bold)),
              label: const Text(
                'New Project',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }

  void _showDeleteDialog(BuildContext context, Project project) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                PhosphorIcons.warning(PhosphorIconsStyle.bold),
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Delete Project'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${project.name}"? This action cannot be undone and will also delete all associated issues.',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<ProjectBloc>().add(
                ProjectDeleteRequested(project.id),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
