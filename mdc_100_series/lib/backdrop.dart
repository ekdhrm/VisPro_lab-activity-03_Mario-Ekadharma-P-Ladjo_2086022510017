import 'package:flutter/material.dart';
import 'model/product.dart';

// The speed at which the backdrop layer animates (flings) open or closed.
const double _kFlingVelocity = 2.0;

class Backdrop extends StatefulWidget {
  final Category currentCategory;
  final Widget frontLayer;
  final Widget backLayer;
  final Widget frontTitle;
  final Widget backTitle;

  const Backdrop({
    required this.currentCategory,
    required this.frontLayer,
    required this.backLayer,
    required this.frontTitle,
    required this.backTitle,
    Key? key,
  }) : super(key: key);

  @override
  _BackdropState createState() => _BackdropState();
}

// We use SingleTickerProviderStateMixin to sync the animation with the screen refresh rate
class _BackdropState extends State<Backdrop>
    with SingleTickerProviderStateMixin {
  final GlobalKey _backdropKey = GlobalKey(debugLabel: 'Backdrop');
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Start with the front layer fully covering the back layer (value 1.0)
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      value: 1.0,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Helper to check if the front layer is visible
  bool get _frontLayerVisible {
    final AnimationStatus status = _controller.status;
    return status == AnimationStatus.completed ||
        status == AnimationStatus.forward;
  }

  // Flings the animation depending on its current state
  void _toggleBackdropLayerVisibility() {
    _controller.fling(
        velocity: _frontLayerVisible ? -_kFlingVelocity : _kFlingVelocity);
  }

  // This builds the stack of layers. LayoutBuilder gives us the screen constraints.
  Widget _buildStack(BuildContext context, BoxConstraints constraints) {
    const double layerTitleHeight = 48.0;
    final Size layerSize = constraints.biggest;
    final double layerTop = layerSize.height - layerTitleHeight;

    // Calculates how far the front layer should slide down
    Animation<RelativeRect> layerAnimation = RelativeRectTween(
      begin: RelativeRect.fromLTRB(
          0.0, layerTop, 0.0, layerTop - layerSize.height),
      end: const RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0),
    ).animate(_controller.view);

    return Stack(
      key: _backdropKey,
      children: <Widget>[
        // The menu in the background
        ExcludeSemantics(
          excluding: _frontLayerVisible,
          child: widget.backLayer,
        ),
        // The sliding front layer wrapped in an animation transition
        PositionedTransition(
          rect: layerAnimation,
          child: _FrontLayer(
            child: widget.frontLayer,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // The App Bar handles the menu icon state
    var appBar = AppBar(
      elevation: 0.0,
      titleSpacing: 0.0,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: _toggleBackdropLayerVisibility,
      ),
      title: _frontLayerVisible ? widget.frontTitle : widget.backTitle,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.search, semanticLabel: 'search'),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.tune, semanticLabel: 'filter'),
          onPressed: () {},
        ),
      ],
    );

    return Scaffold(
      appBar: appBar,
      body: LayoutBuilder(builder: _buildStack),
    );
  }
}

// A customized container for the front layer to give it the Shrine aesthetic
class _FrontLayer extends StatelessWidget {
  const _FrontLayer({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 16.0,
      // This gives us that cool cut-corner design required in MDC-103/104
      shape: const BeveledRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(46.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}