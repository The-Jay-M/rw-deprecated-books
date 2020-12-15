using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class VirtualJoystick : MonoBehaviour, IPointerDownHandler, IDragHandler, IPointerUpHandler 
{
    public Image imgBg;
    public Image imgJoystick;

    private Vector3 inputVector;
    public Vector3 InputVector 
    {
        get 
        {
            return inputVector;
        }
    }


    public void OnPointerDown(PointerEventData e) 
    {
        OnDrag(e);
    }

    public void OnDrag(PointerEventData e) 
    {
        Vector2 pos;
        if (RectTransformUtility.ScreenPointToLocalPointInRectangle(imgBg.rectTransform,
                                                                    e.position,
                                                                    null,
                                                                    out pos)) {

            pos.x = (pos.x / imgBg.rectTransform.sizeDelta.x);
            pos.y = (pos.y / imgBg.rectTransform.sizeDelta.y);

            inputVector = new Vector3(pos.x * 2, 0, pos.y * 2);
            inputVector = (inputVector.magnitude > 1.0f) ? inputVector.normalized : inputVector;

            imgJoystick.rectTransform.anchoredPosition = new Vector3(inputVector.x * (imgBg.rectTransform.sizeDelta.x * .4f),
                                                                     inputVector.z * (imgBg.rectTransform.sizeDelta.y * .4f));
        }
    }   

    public void OnPointerUp(PointerEventData e) 
    {
        inputVector = Vector3.zero;
        imgJoystick.rectTransform.anchoredPosition = Vector3.zero;
    }


    public float Horizontal() 
    {
        if (inputVector.x != 0) 
        {
            return inputVector.x;
        }

        return Input.GetAxis("Horizontal");
    }

    public float Vertical() 
    {
        if (inputVector.z != 0) 
        {
            return inputVector.z;
        }

        return Input.GetAxis("Vertical");
    }
}