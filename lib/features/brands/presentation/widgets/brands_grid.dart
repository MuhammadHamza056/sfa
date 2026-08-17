import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'brand_card.dart';
import 'package:sfa/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:sfa/features/dashboard/bloc/dashboard_event.dart';

class BrandItem {
  final String imageUrl;
  final String name;

  const BrandItem({required this.imageUrl, required this.name});
}

class BrandsGrid extends StatelessWidget {
  final List<BrandItem> brands;

  const BrandsGrid({super.key, required this.brands});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: brands.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1.5,
        mainAxisSpacing: 1.5,
        // portrait cards — taller than wide
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        final brand = brands[index];
        return BrandCard(
          imageUrl: brand.imageUrl,
          brandName: brand.name,
          onTap: () {
            context.read<DashboardBloc>().add(SelectBrandEvent(brand.name));
          },
        );
      },
    );
  }
}
