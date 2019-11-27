import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:hasskit/helper/MaterialDesignIcons.dart';
import 'package:hasskit/helper/ThemeInfo.dart';

class EntityControlToggle extends StatefulWidget {
  final String entityId;

  const EntityControlToggle({@required this.entityId});
  @override
  _EntityControlToggleState createState() => _EntityControlToggleState();
}

class _EntityControlToggleState extends State<EntityControlToggle> {
  double buttonValue = 150;
  double buttonHeight = 300.0;
  double buttonWidth = 90.0;
  double currentPosX;
  double currentPosY;
  double startPosX;
  double startPosY;
  double upperPartHeight = 30.0;
  double buttonWidthInner = 82.0;
  double buttonHeightInner = 123.5;
  double onPos = 300.0 - 123.5 - 4.0;
  double offPos = 4.0;
  double diffY = 0;
  double snap = 10;

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onVerticalDragStart: (DragStartDetails details) =>
          _onVerticalDragStart(context, details),
      onVerticalDragUpdate: (DragUpdateDetails details) =>
          _onVerticalDragUpdate(context, details),
      onVerticalDragEnd: (DragEndDetails details) =>
          _onVerticalDragEnd(context, details),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              Container(
                width: buttonWidth,
                height: buttonHeight,
                decoration: BoxDecoration(
                  color: gd.entities[widget.entityId].isStateOn
                      ? ThemeInfo.colorIconActive
                      : ThemeInfo.colorIconInActive,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      width: 4, color: ThemeInfo.colorBottomSheetReverse),
                ),
              ),
              Positioned(
                bottom: gd.entities[widget.entityId].isStateOn
                    ? onPos + diffY - upperPartHeight
                    : offPos + diffY,
                child: Container(
                  width: buttonWidthInner,
                  height: buttonHeightInner,
                  padding: const EdgeInsets.all(2.0),
                  decoration: new BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(12),
                        bottomLeft: Radius.circular(12)),
                    color: gd.entities[widget.entityId].isStateOn
                        ? Colors.white.withOpacity(1)
                        : Colors.white.withOpacity(1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius:
                            1.0, // has the effect of softening the shadow
                        spreadRadius:
                            0.5, // has the effect of extending the shadow
                        offset: Offset(
                          0.0, // horizontal, move right 10
                          1.0, // vertical, move down 10
                        ),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                          MaterialDesignIcons.getIconDataFromIconName(
                              gd.entities[widget.entityId].getDefaultIcon),
                          size: 70,
                          color: gd.entities[widget.entityId].isStateOn
                              ? ThemeInfo.colorIconActive
                              : ThemeInfo.colorIconInActive),
                      SizedBox(height: 8),
                      Text(
                        gd.textToDisplay(gd.entities[widget.entityId].state),
                        style: ThemeInfo.textStatusButtonActive,
                        maxLines: 1,
                        textScaleFactor:
                            gd.textScaleFactor * 3 / gd.baseSetting.itemsPerRow,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 4,
                child: Container(
                  width: buttonWidth - 8,
                  height: upperPartHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius:
                            0.5, // has the effect of softening the shadow
                        spreadRadius:
                            0.5, // has the effect of extending the shadow
                        offset: Offset(
                          0.0, // horizontal, move right 10
                          -0.5, // vertical, move down 10
                        ),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: RequireSlideToOpen(entityId: widget.entityId),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  _onVerticalDragStart(BuildContext context, DragStartDetails details) {
    final RenderBox box = context.findRenderObject();
    final Offset localOffset = box.globalToLocal(details.globalPosition);
    setState(() {
      startPosX = localOffset.dx;
      startPosY = localOffset.dy;
//      log.d(
//          "_onVerticalDragStart startPosX ${startPosX.toStringAsFixed(0)} startPosY ${startPosY.toStringAsFixed(0)}");
    });
  }

  _onVerticalDragEnd(BuildContext context, DragEndDetails details) {
    setState(
      () {
        log.d("_onVerticalDragEnd");
        diffY = 0;
      },
    );
  }

  _onVerticalDragUpdate(BuildContext context, DragUpdateDetails details) {
    final RenderBox box = context.findRenderObject();
    final Offset localOffset = box.globalToLocal(details.globalPosition);
    setState(() {
      currentPosX = localOffset.dx;
      currentPosY = localOffset.dy;
      diffY = startPosY - currentPosY;
      if (gd.entities[widget.entityId].isStateOn && diffY > 0) diffY = 0;
      if (gd.entities[widget.entityId].isStateOn &&
          diffY <
              buttonHeightInner - buttonHeight + 8 + snap + upperPartHeight) {
        diffY = buttonHeightInner - buttonHeight + 8;
        gd.toggleStatus(gd.entities[widget.entityId]);
      }
      if (!gd.entities[widget.entityId].isStateOn && diffY < 0) diffY = 0;
      if (!gd.entities[widget.entityId].isStateOn &&
          diffY >
              buttonHeight - buttonHeightInner - 8 - snap - upperPartHeight) {
        diffY = buttonHeight - buttonHeightInner - 8;
        gd.toggleStatus(gd.entities[widget.entityId]);
      }
//      print("yDiff $diffY");
    });
  }
}

class RequireSlideToOpen extends StatelessWidget {
  final String entityId;

  const RequireSlideToOpen({@required this.entityId});
  @override
  Widget build(BuildContext context) {
    if (!entityId.contains("cover.")) {
      return Container();
    }

    bool required = false;

    if (gd.entitiesOverride[entityId] != null &&
        gd.entitiesOverride[entityId].openRequireAttention != null &&
        gd.entitiesOverride[entityId].openRequireAttention == true) {
      required = true;
    }

    return InkWell(
      onTap: () {
        gd.requireSlideToOpenAddRemove(entityId);
        Flushbar(
          title: required
              ? "Require Slide to Open Disabled"
              : "Require Slide to Open Enabled",
          message: required
              ? "${gd.textToDisplay(gd.entities[entityId].getOverrideName)} now can be opened with 1 touch"
              : "Prevent accidentally open ${gd.textToDisplay(gd.entities[entityId].getOverrideName)}",
          duration: Duration(seconds: 3),
        )..show(context);
      },
      child: Container(
        width: double.infinity,
        child: FittedBox(
          fit: BoxFit.contain,
          child: Icon(
            required
                ? MaterialDesignIcons.getIconDataFromIconName("mdi:lock")
                : MaterialDesignIcons.getIconDataFromIconName("mdi:lock-open"),
            color: required
                ? ThemeInfo.colorIconActive
                : ThemeInfo.colorIconInActive,
            size: 100,
          ),
        ),
      ),
    );
  }
}
