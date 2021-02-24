package io.openinstall.unity;

import android.content.Intent;
import android.os.Bundle;

import com.fm.openinstall.OpenInstall;
import com.unity3d.player.UnityPlayerActivity;

public class OiUnityActivity extends UnityPlayerActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
//		setContentView(R.layout.activity_main);
        OpenInstallHelper.getWakeUp(getIntent());
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        OpenInstallHelper.getWakeUp(intent);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        OpenInstall.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }
}
