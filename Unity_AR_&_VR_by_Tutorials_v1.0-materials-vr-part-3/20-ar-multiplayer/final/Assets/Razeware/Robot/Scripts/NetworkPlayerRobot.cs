/*
 * Copyright (c) 2018 Razeware LLC
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish, 
 * distribute, sublicense, create a derivative work, and/or sell copies of the 
 * Software in any work that is designed, intended, or marketed for pedagogical or 
 * instructional purposes related to programming, coding, application development, 
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works, 
 * or sale is expressly withheld.
 *    
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

using UnityEngine;
using UnityEngine.Networking;
using UnityEngine.UI;


namespace Razeware.ARBook
{

    [RequireComponent(typeof(NetworkTransform))]
    [RequireComponent(typeof(Rigidbody))]
    public class NetworkPlayerRobot : NetworkBehaviour
    {

        public float rotationSpeed = 45.0f;
        public float speed = 2.0f;
        public float maxSpeed = 3.0f;
        public float moveThreshold = 0.1f;
        public float slowThreshold = 0.5f;
        public float rotateThreshold = 3.0f;

        public float powerUpDuration = 7.0f;
        public float bounceBackDuration = 1.5f;

        public GameObject normalGO;
        public GameObject poweredGO;
        public GameObject scaredGO;
        
        public Renderer[] renderersToColor;

        //Network syncvar
        [SyncVar(hook = "OnScoreChanged")] 
        public int score;
        [SyncVar] 
        public Color color;
        [SyncVar] 
        public string playerName;
        [SyncVar(hook = "OnLifeChanged")] 
        public int lifeCount;
        [SyncVar(hook = "OnPowerUpChanged")] 
        public bool poweredUp;


        protected Rigidbody playerRigidbody;
        protected Collider playerCollider;
        protected Text scoreText;

        protected float playerRotation = 0;

        protected Vector3 targetPosition;

        protected bool canControl = true;

        [SyncVar] protected float powerDownTimer;

        protected float bounceBackTimer;


        //hard to control WHEN Init is called (networking make order between object spawning non deterministic)
        //so we call init from multiple location (depending on what between playerbehavior & manager is created first).
        protected bool wasInit;


        Camera arCamera;
        
        void Awake()
        {
            //register the spaceship in the gamemanager, that will allow to loop on it.
            NetworkRobotGameManager.Robots.Add(this);

            arCamera = PlaneChooser.Instance.GetARCamera();
        }

        void Start()
        {
            playerRigidbody = GetComponent<Rigidbody>();
            playerCollider = GetComponent<Collider>();
            

            foreach (Renderer r in renderersToColor)
            {
                r.material.color = color;
            }

            if (NetworkRobotGameManager.Instance != null)
            {
                //we MAY be awake late (see comment on _wasInit above), so if the instance is already there we init
                Init();
            }
        }

        public void Init()
        {
            if (wasInit)
            {
                return;
            }

            GameObject scoreGO = new GameObject(playerName + "score");
            scoreGO.transform.SetParent(NetworkRobotGameManager.Instance.uiScoreZone.transform, false);
            scoreText = scoreGO.AddComponent<Text>();
            scoreText.alignment = TextAnchor.MiddleCenter;
            scoreText.font = NetworkRobotGameManager.Instance.uiScoreFont;
            scoreText.resizeTextForBestFit = true;
            scoreText.color = color;
            wasInit = true;

            transform.position = NetworkRobotGameManager.Instance.GetPossibleSpawnPosition();
            targetPosition = transform.position;

            bounceBackTimer = 0.0f;
            powerDownTimer = 0.0f;

            lifeCount = 1;
            ChangeGODisplay(normalGO);
            UpdateScoreLifeText();
        }

        void OnDestroy()
        {
            NetworkRobotGameManager.Robots.Remove(this);
        }

        // --- Score & Life management & display
        void OnScoreChanged(int newValue)
        {
            score = newValue;
            UpdateScoreLifeText();
        }

        void OnLifeChanged(int newValue)
        {
            lifeCount = newValue;
            UpdateScoreLifeText();
        }

        void OnPowerUpChanged(bool newValue)
        {
            //set value
            poweredUp = newValue;
            if (poweredUp)
            {
                NetworkRobotGameManager.Instance.RpcPlayPowerUpSound();

                if (isLocalPlayer)
                {
                    //start timer for powerdown
                    powerDownTimer = powerUpDuration;
                }
            }
            else
            {
                NetworkRobotGameManager.Instance.RpcPlayPowerDownSound();
            }
        }

        [Command]
        void CmdPowerUp(bool enablePU)
        {
            ServerPowerUp(enablePU);
        }

        [Server]
        public void ServerPowerUp(bool enablePU)
        {
            poweredUp = enablePU;
            NetworkRobotGameManager.Instance.CheckPowerUpInfo();
        }

        [ClientRpc]
        public void RpcPlayerNormalGO()
        {
            ChangeGODisplay(normalGO);
        }

        [ClientRpc]
        public void RpcPlayerPoweredGO()
        {
            ChangeGODisplay(poweredGO);
        }

        [ClientRpc]
        public void RpcPlayerScaredGO()
        {
            ChangeGODisplay(scaredGO);
        }

        void ChangeGODisplay(GameObject go)
        {
            normalGO.SetActive(go == normalGO);
            poweredGO.SetActive(go == poweredGO);
            scaredGO.SetActive(go == scaredGO);
        }


        void UpdateScoreLifeText()
        {
            if (scoreText != null)
            {
                scoreText.text = playerName + "\nSCORE : " + score + "\nLIFE : ";
                for (int i = 1; i <= lifeCount; ++i)
                {
                    scoreText.text += "X";
                }
            }
        }

        [ClientCallback]
        void Update()
        {
            playerRotation = 0;

            if (!isLocalPlayer || !canControl)
            {
                return;
            }

            if (powerDownTimer > 0.0f)
            {
                powerDownTimer -= Time.deltaTime;
                if (powerDownTimer <= 0.0f)
                {
                    CmdPowerUp(false);
                }
            }


            if (bounceBackTimer > 0.0f)
            {
                bounceBackTimer -= Time.deltaTime;
                return; //don't allow user interaction if bouncing
            }

            if (Input.GetMouseButton(0))
            {

                Ray ray = arCamera.ScreenPointToRay(Input.mousePosition);

                int layerMask = 1 << LayerMask.NameToLayer("Floor"); // Planes are in layer Floor

                RaycastHit rayHit;
                if (Physics.Raycast(ray, out rayHit, float.MaxValue, layerMask))
                {
                    targetPosition = rayHit.point;
                }
            }

        }


        [ClientCallback]
        void FixedUpdate()
        {
            if (!hasAuthority)
            {
                return;
            }

            if (!canControl)
            {
                //if we can't control, mean we're destroyed, so make sure the ship stay in spawn place
                playerRigidbody.rotation = Quaternion.identity;
                playerRigidbody.position = Vector3.zero;
                playerRigidbody.velocity = Vector3.zero;
                playerRigidbody.angularVelocity = Vector3.zero;
            }
            else
            {
                Vector3 toTarget = (targetPosition - transform.position);
                toTarget = new Vector3(toTarget.x, 0.0f, toTarget.z);
                if (toTarget.magnitude > moveThreshold)
                {

                    //rotate to face target
                    float diffAngle = Vector3.SignedAngle(transform.forward, toTarget.normalized, Vector3.up);
                    float absDiffAngle = Mathf.Abs(diffAngle);
                    if (absDiffAngle > rotateThreshold)
                    {
                        float rotAngle = rotationSpeed * Time.fixedDeltaTime;
                        rotAngle = absDiffAngle > rotAngle ? rotAngle : absDiffAngle;
                        rotAngle = diffAngle > 0.0f ? rotAngle : -rotAngle;
                        playerRigidbody.rotation = playerRigidbody.rotation * Quaternion.Euler(0, rotAngle, 0);
                    }

                    //slowdown as you get closer
                    float slowdownFactor = (toTarget.magnitude / slowThreshold);
                    slowdownFactor = slowdownFactor > 1.0f ? 1.0f : slowdownFactor;

                    playerRigidbody.velocity = toTarget.normalized * speed * slowdownFactor;

                    if (playerRigidbody.velocity.magnitude > maxSpeed)
                    {
                        playerRigidbody.velocity = playerRigidbody.velocity.normalized * maxSpeed;
                    }
                }
                else
                {
                    playerRigidbody.velocity = Vector3.zero;
                    playerRigidbody.angularVelocity = Vector3.zero;
                }
            }
        }

        [ClientRpc]
        void RpcBounceBackTo(Vector3 newPosition)
        {
            targetPosition = newPosition;
            bounceBackTimer = bounceBackDuration;
        }

        [ServerCallback]
        void OnCollisionEnter(Collision coll)
        {
            if (coll.gameObject.tag == "Player")
            {
                //we collided with a player, check if they are powered up.
                NetworkPlayerRobot otherRobot = coll.gameObject.GetComponent<NetworkPlayerRobot>();
                if (otherRobot.poweredUp && !poweredUp)
                {
                    Killed();
                }
                else
                {
                    BounceBack(otherRobot.gameObject.transform);
                }
            }
        }

        [Server]
        public void Killed()
        {
            lifeCount = 0;
            //show dying animation

            NetworkRobotGameManager.Instance.RpcPlayDeathSound();
            
            //destroy the player
            NetworkServer.Destroy(gameObject);

        }
        

        [Server]
        public void BounceBack(Transform otherPlayer)
        {
            Vector3 diff = transform.position - otherPlayer.position;

            RpcBounceBackTo(transform.position + (diff * 3.0f));

        }
    }
}
