using UnityEngine;
using UnityEngine.UI;

public class ModeSwitcher : MonoBehaviour
{

	public GameObject dropObjects;
	public GameObject moveObjects;

	private int appMode;
	
	void Start()
	{
		appMode = 0;
		dropObjects.SetActive(appMode == 0);
		moveObjects.SetActive(appMode == 1);
	}
	
	public void ButtonToggle(Text description) 
	{
		appMode = (appMode + 1) % 2;
		description.text = (appMode == 0) ? "Drop Mode" : "Push Mode";
		
		dropObjects.SetActive(appMode == 0);
		moveObjects.SetActive(appMode == 1);
	}
}
