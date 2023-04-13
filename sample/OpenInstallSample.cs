using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using io.openinstall.unity;

public class OpenInstallSample : MonoBehaviour {
    private OpenInstall openinstall;

    public Text installResult;
    public Text wakeupResult;

    // Use this for initialization
    void Start () {
		Debug.Log("OpenInstall Sample Start");
        openinstall = GameObject.Find("OpenInstall").GetComponent<OpenInstall>();
		// 在初始化前，需要用户阅读并同意《隐私政策》
        openinstall.Init();
		// 注册唤醒监听
        openinstall.RegisterWakeupHandler(getWakeupFinish); 
		// 获取安装参数 
		openinstall.GetInstall(8, getInstallFinish);		
        wakeupResult = GameObject.Find("wakeupResult").GetComponent<Text>();
        installResult = GameObject.Find("installResult").GetComponent<Text>();
    }
	
	// Update is called once per frame
	void Update () {
		
	}


    public void getInstallButtonClick()
    {
        Debug.Log("OpenInstallSample getInstall button click");
        openinstall.GetInstall(8, getInstallFinish);
    }

    public void reportRegisterButtonClick()
    {
        Debug.Log("OpenInstallSample reportRegister button click");
        openinstall.ReportRegister();
    }

    public void reportEffectPointButtonClick()
    {
        Debug.Log("OpenInstallSample reportEffectPoint button click");
        openinstall.ReportEffectPoint("effect_test", 1);
    }

    public void reportShareButtonClick()
    {
        Debug.Log("OpenInstallSample reportShare button click");
        openinstall.ReportShare("123456", "QQ", reportFinish);
    }

    // callback
    public void getInstallFinish(OpenInstallData installData)
    {
        Debug.Log("OpenInstallSample getInstallFinish : 渠道编号=" + installData.channelCode + "，自定义数据=" + installData.bindData);
        installResult.text = "安装参数：" + JsonUtility.ToJson(installData);
    }

    public void getWakeupFinish(OpenInstallData wakeupData)
    {
        Debug.Log("OpenInstallSample getWakeupFinish : 渠道编号=" + wakeupData.channelCode + "， 自定义数据=" + wakeupData.bindData);
        wakeupResult.text = "拉起参数：" + JsonUtility.ToJson(wakeupData);
    }
	
    public void reportFinish(OpenInstallData reportData)
    {
        Debug.Log("OpenInstallSample reportFinish : shouldRetry=" + reportData.shouldRetry);
    }

}
