import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageSourcePicker extends StatelessWidget {
  final ValueChanged<ImageSource> onSourceSelected;

  const ImageSourcePicker({
    super.key,
    required this.onSourceSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ambil Foto Struk',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSourceTile(
                context,
                icon: Icons.camera_alt_rounded,
                label: 'Kamera',
                source: ImageSource.camera,
              ),
              _buildSourceTile(
                context,
                icon: Icons.photo_library_rounded,
                label: 'Galeri',
                source: ImageSource.gallery,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSourceTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required ImageSource source,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        onSourceSelected(source);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(label, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
