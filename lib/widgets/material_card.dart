import 'package:flutter/material.dart';
import '../models/material.dart';

class MaterialCard extends StatelessWidget {
  final StudyMaterial material;
  final VoidCallback onTradeRequest;

  const MaterialCard({
    Key? key,
    required this.material,
    required this.onTradeRequest,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(material.title),
        subtitle: Text('${material.category} - ${material.condition}'),
        trailing: IconButton(
          icon: const Icon(Icons.swap_horiz),
          onPressed: onTradeRequest,
        ),
      ),
    );
  }
}