package com.az.quiz;

import android.os.Bundle;
import android.content.Intent;
import android.net.Uri;


import java.util.Map;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class MainActivity extends FlutterActivity {

  private static final String CHANNEL = "com.az.quiz/intent";

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(new MethodChannel.MethodCallHandler(){
      @Override
      public void onMethodCall(MethodCall methodCall, MethodChannel.Result result){
        final String message = methodCall.arguments();
        if(methodCall.method.equals("referralIntent")){
          Intent intent = new Intent(Intent.ACTION_SEND);
          intent.setType("text/plain");
          intent.putExtra(Intent.EXTRA_TEXT, message);
          if(intent.resolveActivity(getPackageManager()) != null){
            startActivity(Intent.createChooser(intent, "Share App!"));
          }
          
        }else if(methodCall.method.equals("callIntent")){
          Uri uri = Uri.parse("tel:9078600468");
          Intent intent = new Intent(Intent.ACTION_CALL, uri);
          if(intent.resolveActivity(getPackageManager())!=null){
            startActivity(Intent.createChooser(intent, "Call using..."));
          }
        }else if(methodCall.method.equals("facebookIntent")){
          Uri uri = Uri.parse("https://www.facebook.com/soleigit/");
          Intent intent = new Intent(Intent.ACTION_VIEW, uri);
          if(intent.resolveActivity(getPackageManager()) != null){
            startActivity(Intent.createChooser(intent, "Open with..."));
          }
        }
      }
    });
  }
}
