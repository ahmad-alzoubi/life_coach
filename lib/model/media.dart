class Media {
  final String id;
  final String modelType;
  final String modelId;
  final String uuid;
  final String collectionName;
  final String name;
  final String fileName;
  final String mimeType;
  final String disk;
  final String conversionsDisk;
  final int size;
  final String manipulations;
  final String customProperties;
  final String responsiveImages;  
  final String orderColumn;
  final String createdAt;
  final String updatedAt;
  final String originalUrl;

  Media({
    required this.id,
    required this.modelType,
    required this.modelId,
    required this.uuid,
    required this.collectionName,
    required this.name,
    required this.fileName,
    required this.mimeType,
    required this.disk,
    required this.conversionsDisk,
    required this.size,
    required this.manipulations,
    required this.customProperties,
    required this.responsiveImages,
    required this.orderColumn,
    required this.createdAt,
    required this.updatedAt,
    required this.originalUrl,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'].toString(),
      modelType: json['model_type'].toString(),
      modelId: json['model_id'].toString(),
      uuid: json['uuid'].toString(),
      collectionName: json['collection_name'].toString(),
      name: json['name'].toString(),
      fileName: json['file_name'].toString(),
      mimeType: json['mime_type'].toString(),
      disk: json['disk'].toString(),
      conversionsDisk: json['conversions_disk'].toString(),
      size: int.parse(json['size'].toString()),
      manipulations: json['manipulations'].toString(),
      customProperties: json['custom_properties'].toString(),
      responsiveImages: json['responsive_images'].toString(),
      orderColumn: json['order_column'].toString(),
      createdAt: json['created_at'].toString(),
      updatedAt: json['updated_at'].toString(),
      originalUrl: json['original_url'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'model_type': modelType,
      'model_id': modelId,
      'uuid': uuid,
      'collection_name': collectionName,
      'name': name,
      'file_name': fileName,
      'mime_type': mimeType,
      'disk': disk,
      'conversions_disk': conversionsDisk,
      'size': size,
      'manipulations': manipulations,
      'custom_properties': customProperties,
      'responsive_images': responsiveImages,
      'order_column': orderColumn,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'original_url': originalUrl,
    };
  }

}