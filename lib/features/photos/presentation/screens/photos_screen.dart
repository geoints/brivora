import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

import '../../domain/models/photo.dart';
import '../providers/photos_provider.dart';
import '../../../projects/data/repositories/project_repository.dart';

class PhotosScreen extends StatelessWidget {
  final String projectId;

  const PhotosScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PhotosProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Фото объекта'),
        actions: [
          StreamBuilder<List<Photo>>(
            stream: provider.getPhotos(projectId),
            builder: (context, snapshot) {
              final count = snapshot.data?.length ?? 0;
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text('$count', style: Theme.of(context).textTheme.titleMedium),
                ),
              );
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (_) {
              return SafeArea(
                child: Wrap(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('Выбрать из галереи'),
                      onTap: () async {
                        Navigator.pop(context);

                        await provider.uploadPhoto(projectId);
                      },
                    ),

                    ListTile(
                      leading: const Icon(Icons.photo_camera),
                      title: const Text('Сделать фото'),
                      onTap: () async {
                        Navigator.pop(context);

                        await provider.uploadFromCamera(projectId);
                      },
                    ),

                    ListTile(
                      leading: const Icon(Icons.close),
                      title: const Text('Отмена'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add_a_photo_rounded),
      ),

      body: StreamBuilder<List<Photo>>(
        stream: provider.getPhotos(projectId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Ошибка загрузки фотографий:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final photos = snapshot.data ?? [];

          if (photos.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library_outlined, size: 80),

                  SizedBox(height: 16),

                  Text(
                    'Фотографий пока нет',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 8),

                  Text('Нажмите + чтобы добавить первое фото'),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),

            itemCount: photos.length,

            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 12,
              childAspectRatio: 0.88,
            ),

            itemBuilder: (context, index) {
              final photo = photos[index];

              return GestureDetector(
                onTap: () {
                  _openPhoto(context, photos, index);
                },

                onLongPress: () async {
                  final action = await showModalBottomSheet<String>(
                    context: context,
                    builder: (_) {
                      return SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.edit_note),
                              title: const Text('Редактировать подпись'),
                              onTap: () {
                                Navigator.pop(context, 'edit_caption');
                              },
                            ),

                            ListTile(
                              leading: const Icon(Icons.star),
                              title: const Text('Сделать обложкой'),
                              onTap: () {
                                Navigator.pop(context, 'cover');
                              },
                            ),

                            ListTile(
                              leading: const Icon(Icons.delete),
                              title: const Text('Удалить'),
                              onTap: () {
                                Navigator.pop(context, 'delete');
                              },
                            ),

                            ListTile(
                              leading: const Icon(Icons.close),
                              title: const Text('Отмена'),
                              onTap: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );

                  if (!context.mounted) {
                    return;
                  }

                  if (action == 'edit_caption') {
                    await _showEditCaptionDialog(context, photo);
                  }

                  if (action == 'cover') {
                    await _setAsCover(context, photo);
                  }

                  if (action == 'delete') {
                    await _deletePhoto(context, provider, photo);
                  }
                },

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Hero(
                        tag: photo.id,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: CachedNetworkImage(
                            imageUrl: photo.imageUrl,
                            fit: BoxFit.cover,

                            placeholder: (_, _) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },

                            errorWidget: (_, _, _) {
                              return const Center(
                                child: Icon(Icons.error_outline, size: 40),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    if (photo.caption.isNotEmpty) ...[
                      const SizedBox(height: 8),

                      Text(
                        photo.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _setAsCover(BuildContext context, Photo photo) async {
    try {
      await ProjectRepository().setProjectCover(projectId, photo.imageUrl);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Обложка проекта обновлена ⭐')),
      );

      // Возвращаем true на ProjectDetailsScreen,
      // чтобы он заново загрузил проект.
      Navigator.pop(context, true);
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось установить обложку: $e')),
      );
    }
  }

  Future<void> _deletePhoto(
    BuildContext context,
    PhotosProvider provider,
    Photo photo,
  ) async {
    try {
      await provider.deletePhoto(photo);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Фото удалено')));
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Не удалось удалить фото: $e')));
    }
  }

  Future<void> _showEditCaptionDialog(BuildContext context, Photo photo) async {
    final controller = TextEditingController(text: photo.caption);

    final caption = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Редактировать подпись'),

          content: TextField(
            controller: controller,
            maxLines: null,
            decoration: const InputDecoration(
              hintText: 'Введите подпись для фото',
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Отмена'),
            ),

            FilledButton(
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (!context.mounted) {
      return;
    }

    if (caption != null && caption != photo.caption) {
      try {
        await context.read<PhotosProvider>().updatePhotoCaption(photo, caption);
      } catch (e) {
        if (!context.mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось изменить подпись: $e')),
        );
      }
    }
  }

  void _openPhoto(BuildContext context, List<Photo> photos, int initialIndex) {
    final controller = PageController(initialPage: initialIndex);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          return Scaffold(
            backgroundColor: Colors.black,

            appBar: AppBar(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              title: const Text('Просмотр фото'),
            ),

            body: PageView.builder(
              controller: controller,
              itemCount: photos.length,

              itemBuilder: (context, index) {
                final photo = photos[index];

                return Hero(
                  tag: photo.id,
                  child: PhotoView(
                    imageProvider: CachedNetworkImageProvider(photo.imageUrl),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 3,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
