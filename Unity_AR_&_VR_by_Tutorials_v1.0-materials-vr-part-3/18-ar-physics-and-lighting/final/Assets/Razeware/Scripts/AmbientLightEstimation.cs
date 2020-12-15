using UnityEngine;
using UnityEngine.XR.ARFoundation;

[RequireComponent(typeof(Light))]
public class AmbientLightEstimation : MonoBehaviour 
{
	private Light lightComponent;

	void OnEnable() 
	{
		lightComponent = GetComponent<Light>();
		ARSubsystemManager.cameraFrameReceived += OnCameraFrameReceived;
	}

	void OnCameraFrameReceived(ARCameraFrameEventArgs camFrameEvent)
	{
		LightEstimationData led = camFrameEvent.lightEstimation;

		if (led.averageBrightness.HasValue) 
		{
			lightComponent.intensity = led.averageBrightness.Value;
		}

		if (led.averageColorTemperature.HasValue) 
		{
			lightComponent.colorTemperature = led.averageColorTemperature.Value;
		}
	} 

	void OnDisable() 
	{
		ARSubsystemManager.cameraFrameReceived -= OnCameraFrameReceived;
	}

}
