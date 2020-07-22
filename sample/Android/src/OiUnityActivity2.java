package io.openinstall.unityplugin;

import android.content.Intent;
import android.os.Bundle;

import com.fm.openinstall.OpenInstall;
import com.unity3d.player.UnityPlayerActivity;

import io.openinstall.unity.OiWakeupCallback;

/**
 * 用于需要申请权限时使用
 */
public class OiUnityActivity2 extends UnityPlayerActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
//		setContentView(R.layout.activity_main);

        OpenInstall.initWithPermission(this, new Runnable() {
            @Override
            public void run() {
                OpenInstall.getWakeUp(getIntent(), wakeupCallback);
            }
        });

    }


    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        OpenInstall.getWakeUp(intent, wakeupCallback);

    }

    OiWakeupCallback wakeupCallback = new OiWakeupCallback();

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        OpenInstall.onRequestPermissionsResult(requestCode, permissions, grantResults);
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }
}
