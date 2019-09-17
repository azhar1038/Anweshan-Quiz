import 'package:flare_dart/math/mat2d.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_controller.dart';

class GoogleLoadController extends FlareController{
  
  bool play;

  GoogleLoadController({this.play});

  ActorAnimation _arrange;
  ActorAnimation _load;
  double time = 0.0;
  double time2 = 0.0;
  @override
  bool advance(FlutterActorArtboard artboard, double elapsed) {
    if(play){
    time = time+elapsed;
    time2 = time%_load.duration;
    _arrange.apply(time, artboard, 1.0);
    if(time > 0.5){
      _load.apply(time2, artboard, 1.0);
    }}
    else{
    _arrange.apply(0, artboard, 1.0);
    time=0;
    }
    return true;
  }

  @override
  void initialize(FlutterActorArtboard artboard) {
    _arrange = artboard.getAnimation("arrange");
    _load = artboard.getAnimation('load');
  }

  @override
  void setViewTransform(Mat2D viewTransform) {
  }
  
}