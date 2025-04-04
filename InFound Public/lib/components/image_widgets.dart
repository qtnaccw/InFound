import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:infound/components/containers.dart';
import 'package:infound/utils/styles.dart';

enum ImageType { asset, network, memory, file }

class AppRoundedImage extends StatelessWidget {
  const AppRoundedImage({
    super.key,
    this.image,
    this.file,
    this.border,
    this.width = double.infinity,
    this.height = double.infinity,
    this.memoryImage,
    this.overlayColor,
    required this.imageType,
    this.backgroundColor,
    this.padding = 0,
    this.margin,
    this.fit = BoxFit.contain,
    this.applyImageRadius = true,
    this.borderRadius = 0,
    this.colorBlendMode,
  });

  final bool applyImageRadius;
  final BoxBorder? border;
  final double borderRadius;
  final BoxFit? fit;
  final String? image;
  final File? file;
  final ImageType imageType;
  final Color? overlayColor;
  final Color? backgroundColor;
  final Uint8List? memoryImage;
  final double width, height, padding;
  final double? margin;
  final BlendMode? colorBlendMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin != null ? EdgeInsets.all(margin!) : null,
      padding: EdgeInsets.all(padding),
      decoration:
          BoxDecoration(border: border, color: backgroundColor, borderRadius: BorderRadius.circular(borderRadius)),
      child: _buildImageWidget(),
    );
  }

  Widget _buildImageWidget() {
    Widget imageWidget;

    switch (imageType) {
      case ImageType.network:
        imageWidget = _buildNetworkImage();
        break;
      case ImageType.memory:
        imageWidget = _buildMemoryImage();
        break;
      case ImageType.file:
        imageWidget = _buildFileImage();
        break;
      case ImageType.asset:
        imageWidget = _buildAssetImage();
        break;
    }

    // Apply ClipRRect directly to the image widget
    return ClipRRect(
      borderRadius: applyImageRadius ? BorderRadius.circular(borderRadius) : BorderRadius.zero,
      child: imageWidget,
    );
  }

  // Function to build the network image widget
  Widget _buildNetworkImage() {
    if (image != null) {
      // Use CachedNetworkImage for efficient loading and caching of network images // Not working in Web but just for loading
      return CachedNetworkImage(
        fit: fit,
        color: overlayColor,
        colorBlendMode: colorBlendMode,
        imageUrl: image!,
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          color: AppStyles.lightGrey,
          child: const Icon(
            Icons.error,
            color: AppStyles.pureWhite,
          ),
        ),
        progressIndicatorBuilder: (context, url, downloadProgress) => AppShimmerEffect(width: width, height: height),
      );
    } else {
      // Return an empty container if no image is provided
      return Container();
    }
  }

  // Function to build the memory image widget
  Widget _buildMemoryImage() {
    if (memoryImage != null) {
      // Display image from memory using Image widget
      return Image(
        fit: fit,
        image: MemoryImage(memoryImage!),
        color: overlayColor,
        colorBlendMode: colorBlendMode,
      );
    } else {
      // Return an empty container if no image is provided
      return Container();
    }
  }

  // Function to build the asset image widget
  Widget _buildFileImage() {
    if (file != null) {
      // Display image from assets using Image widget
      return Image(
        fit: fit,
        image: FileImage(file!),
        color: overlayColor,
        colorBlendMode: colorBlendMode,
      );
    } else {
      // Return an empty container if no image is provided
      return Container();
    }
  }

  // Function to build the asset image widget
  Widget _buildAssetImage() {
    if (image != null) {
      // Display image from assets using Image widget
      return Image(
        fit: fit,
        image: AssetImage(image!),
        color: overlayColor,
        colorBlendMode: colorBlendMode,
      );
    } else {
      // Return an empty container if no image is provided
      return Container();
    }
  }
}
