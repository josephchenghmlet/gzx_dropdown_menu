import 'package:flutter/material.dart';

import 'gzx_dropdown_menu_controller.dart';

class GZXDropdownMenuBuilder {
  final Widget dropDownWidget;
  final double dropDownHeight;

  GZXDropdownMenuBuilder({@required this.dropDownWidget, @required this.dropDownHeight});
}

class GZXDropDownMenu extends StatefulWidget {
  final GZXDropdownMenuController controller;
  final List<GZXDropdownMenuBuilder> menus;
  final int animationMilliseconds;

  const GZXDropDownMenu({Key key, @required this.controller, @required this.menus, this.animationMilliseconds = 500})
      : super(key: key);

  @override
  _GZXDropDownMenuState createState() => _GZXDropDownMenuState();
}

class _GZXDropDownMenuState extends State<GZXDropDownMenu> with SingleTickerProviderStateMixin {
  bool _isShowDropDownItemWidget = false;
  bool _isShowMask = false;

  Animation<double> _animation;
  AnimationController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    widget.controller.addListener(_onController);
    _controller = new AnimationController(duration: Duration(milliseconds: widget.animationMilliseconds), vsync: this);
  }

  _onController() {
//    print('_GZXDropDownMenuState._onController ${widget.controller.menuIndex}');

    _showDropDownItemWidget();
  }

  @override
  Widget build(BuildContext context) {
//    print('_GZXDropDownMenuState.build');
    _controller.duration = Duration(milliseconds: widget.animationMilliseconds);
    return _buildDropDownWidget();
  }

  dispose() {
    _controller.dispose();
    super.dispose();
  }

  _showDropDownItemWidget() {
    int menuIndex = widget.controller.menuIndex;
    if (menuIndex >= widget.menus.length || widget.menus[menuIndex] == null) {
      return;
    }

    _isShowDropDownItemWidget = !_isShowDropDownItemWidget;
    _isShowMask = !_isShowMask;

    _animation = new Tween(begin: 0.0, end: widget.menus[menuIndex].dropDownHeight).animate(_controller)
      ..addListener(() {
        //这行如果不写，没有动画效果
        setState(() {});
      });

    if (_animation.status == AnimationStatus.completed) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  _hideDropDownItemWidget() {
    _isShowDropDownItemWidget = !_isShowDropDownItemWidget;
    _isShowMask = !_isShowMask;
    _controller.reverse();
  }

  Widget _mask() {
    if (_isShowMask) {
      return GestureDetector(
        onTap: () {
          _hideDropDownItemWidget();
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Color.fromRGBO(0, 0, 0, 0.1),
        ),
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  Widget _buildDropDownWidget() {
    int menuIndex = widget.controller.menuIndex;

    return Positioned(
        width: MediaQuery.of(context).size.width,
        top: widget.controller.dropDownHearderHeight,
        left: 0,
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              height: _animation == null ? 0 : _animation.value,
              child: widget.menus[menuIndex].dropDownWidget,
            ),
            _mask()
          ],
        ));
  }
}
