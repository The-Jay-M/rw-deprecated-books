using UnityEngine;

public class MoveObjects : MonoBehaviour 
{
    public GameObject wreckerGo;

    // Update is called once per frame
    void Update() 
    {
        if (!isActiveAndEnabled)
        {
            return;
        }

        if (Input.GetMouseButton(0)) 
        {
            var camera = Camera.main;

            Ray ray = camera.ScreenPointToRay(Input.mousePosition);

            int layerMask = 1 << LayerMask.NameToLayer("ARGameObject"); // generated planes are in layer ARGameObject

            RaycastHit rayHit;
            if (Physics.Raycast(ray, out rayHit, float.MaxValue, layerMask)) 
            {
                if (wreckerGo.activeSelf)
                {
                    //move it from current position to where we are leading it
                    wreckerGo.transform.position = Vector3.MoveTowards(wreckerGo.transform.position, rayHit.point, 0.1f);
                }
                else
                {
                    wreckerGo.transform.position = rayHit.point;
                    wreckerGo.SetActive(true);
                }
            }
            else
            {
                //we're no longer on the plane
                wreckerGo.SetActive(false);
            }
        } 
        else 
        {
            //we're no longer touching screen
            wreckerGo.SetActive(false);
        }

    }

}
