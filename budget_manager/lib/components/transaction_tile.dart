import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TransactionTile extends StatelessWidget {
  final String detail;
  final String category;
  final String amount;
  final String date;
  final IconData icon;
  final double percentFilled;
  final Color categoryColor;

  TransactionTile(
      {this.category,
      this.detail,
      this.amount,
      this.date,
      this.icon,
      this.percentFilled,
      this.categoryColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: <BoxShadow>[BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: Alignment(0, 0), // near the top right
                        radius: 0.8,
                        colors: [
                          this.categoryColor,
                          this.categoryColor.withOpacity(.2),
                        ],
                      ),
//                      LinearGradient(
//                        begin: Alignment.topLeft,
//                        end: Alignment.bottomRight,
//                        colors: [
//                          Color(0xffFE6B8D),
//                          Color(0xffFE6B8D).withOpacity(.5),
//                        ],
//                        tileMode: TileMode.repeated,
//                      ),
                      //    color: Color(0xffFE6B8D),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: this.categoryColor.withOpacity(.6),
                            blurRadius: 10,
                            offset: Offset.fromDirection(.6, 2))
                      ],
                    ),
                    child: Stack(
                      children: <Widget>[
                        CircleAvatar(
                          child: Icon(this.icon),
                          backgroundColor: Colors.transparent,
                          //     backgroundColor: Color(0xffFE6B8D),
                          foregroundColor: Colors.white,
                        ),
                        PieChart(
                          PieChartData(
                            centerSpaceRadius: 0,
                            sectionsSpace: 0,
                            borderData: FlBorderData(show: false),
                            startDegreeOffset: 250,
                            sections: <PieChartSectionData>[
                              PieChartSectionData(
                                color: Colors.transparent,
                                value: 1 - this.percentFilled,
                                radius: 20,
                                title: "",
                              ),
                              PieChartSectionData(
                                color: Colors.white.withOpacity(0.4),
                                //       color: const Color(0xff000000).withOpacity(0.2),
                                value: this.percentFilled,
                                radius: 20,
                                title: "",
                              )
                            ],
                          ),
                        ),
                      ],
                      alignment: AlignmentDirectional.center,
                    ),
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      this.category,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2),
                    ),
                    SizedBox(
                      height: 3.0,
                    ),
                    Text(
                      this.detail,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    "${this.amount}",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2),
                  ),
                  SizedBox(
                    height: 3.0,
                  ),
                  Text(
                    this.date,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
