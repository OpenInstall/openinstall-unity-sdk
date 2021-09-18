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

}
