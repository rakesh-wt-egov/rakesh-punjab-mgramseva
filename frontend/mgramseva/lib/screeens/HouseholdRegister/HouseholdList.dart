
import 'package:flutter/material.dart';
import 'package:mgramseva/components/Dashboard/BillsTable.dart';
import 'package:mgramseva/model/connection/water_connection.dart';
import 'package:mgramseva/providers/household_register_provider.dart';
import 'package:mgramseva/utils/Locilization/application_localizations.dart';
import 'package:mgramseva/utils/common_widgets.dart';
import 'package:mgramseva/utils/loaders.dart';
import 'package:mgramseva/utils/notifyers.dart';
import 'package:provider/provider.dart';
import 'package:mgramseva/utils/Constants/I18KeyConstants.dart';

class HouseholdList extends StatefulWidget {
  const HouseholdList({Key? key}) : super(key: key);

  @override
  _HouseholdListState createState() => _HouseholdListState();
}

class _HouseholdListState extends State<HouseholdList> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var householdProvider = Provider.of<HouseholdRegisterProvider>(context, listen: false);
    return StreamBuilder(
        stream: householdProvider.streamController.stream,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if(snapshot.data is String){
              return CommonWidgets.buildEmptyMessage(snapshot.data, context);
            }
            return _buildTabView(snapshot.data);
          } else if (snapshot.hasError) {
            return Notifiers.networkErrorPage(context, () => {});
          } else {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Loaders.CircularLoader();
              case ConnectionState.active:
                return Loaders.CircularLoader();
              default:
                return Container();
            }
          }
        });
  }


  Widget _buildTabView(List<dynamic> expenseList) {
    var householdProvider = Provider.of<HouseholdRegisterProvider>(context, listen: false);

    return LayoutBuilder(
        builder : (context, constraints) {
          var width = constraints.maxWidth < 760 ? 145.0  : (constraints.maxWidth / 4);
          var tableData = householdProvider.getCollectionsData(expenseList  as List<WaterConnection>);
          return tableData == null || tableData.isEmpty ?
          CommonWidgets.buildEmptyMessage(ApplicationLocalizations.of(context).translate(i18.dashboard.NO_RECORDS_MSG), context)
              : BillsTable
            (headerList: householdProvider.collectionHeaderList,
            tableData:  tableData,
            leftColumnWidth: width,
            rightColumnWidth: width * 3 ,
            height: 68 + (52.0 * tableData.length),
          );
        }
    );
  }
}
