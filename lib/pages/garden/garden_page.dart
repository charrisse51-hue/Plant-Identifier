import 'package:flutter/material.dart';
import 'package:flutter_projects/color/app_colors.dart';
import 'package:provider/provider.dart';

import '../history/history_page.dart';
import '../myplants/myplants_page.dart';
import 'garden_page_model.dart';

class GardenPage extends StatelessWidget {
  const GardenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GardenPageModel(),
      child: const _GardenPageView(),
    );
  }
}

class _GardenPageView extends StatelessWidget {
  const _GardenPageView();

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<GardenPageModel>(context, listen: false);

    return SafeArea(
      bottom: false,
      child: DefaultTabController(
        length: 2,
        child: Builder(
          builder: (context) {
            final tabController = DefaultTabController.of(context);
            tabController.addListener(model.onTabChanged);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TabBar(
                  tabs: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Tab(text: 'My Plants'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Tab(text: 'History'),
                    ),
                  ],
                  isScrollable: false,
                  indicatorColor: AppColors.primaryA0,
                  labelColor: AppColors.primaryA0,
                  unselectedLabelColor: AppColors.surfaceA50,
                  labelStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      MyplantsPage(),
                      HistoryPage(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
