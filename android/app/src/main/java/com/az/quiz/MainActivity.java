package com.az.quiz;

import android.os.Bundle;
import android.content.Intent;
import android.net.Uri;
import android.Manifest;
import android.content.pm.PackageManager;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;


import java.util.Map;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class MainActivity extends FlutterActivity {

  private static final String CHANNEL = "com.az.quiz/intent";

  private static final int GET_PHONE_PERMISSION_REQUEST_ID = 2546;

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
          if(ContextCompat.checkSelfPermission(this.activity(),
            Manifest.permission.CALL_PHONE) != PackageManager.PERMISSION_GRANTED){
              ActivityCompat.requestPermission(this, new String[]{Manifest.permission.CALL_PHONE}, GET_PHONE_PERMISSION_REQUEST_ID);
          }else {
            Uri uri = Uri.parse("tel:9439717907");
            Intent intent = new Intent(Intent.ACTION_CALL, uri);
            if (intent.resolveActivity(getPackageManager()) != null) {
              startActivity(Intent.createChooser(intent, "Call using..."));
            }
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

  @Override
  public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
    if(requestCode == GET_PHONE_PERMISSION_REQUEST_ID){
      if(grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED){
        Uri uri = Uri.parse("tel:9439717907");
        Intent intent = new Intent(Intent.ACTION_CALL, uri);
        if (intent.resolveActivity(getPackageManager()) != null) {
          startActivity(Intent.createChooser(intent, "Call using..."));
        }
      }
    }
    //super.onRequestPermissionsResult(requestCode, permissions, grantResults);
  }
}
