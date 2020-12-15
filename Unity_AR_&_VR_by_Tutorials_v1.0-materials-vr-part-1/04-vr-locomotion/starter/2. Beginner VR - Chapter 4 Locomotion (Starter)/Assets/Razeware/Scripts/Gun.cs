using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Gun : Weapon
{
    [SerializeField] public float damage;
    [SerializeField] public int ammoCount;
    [SerializeField] public float reloadTime;
    [SerializeField] public float fireRate;
    [SerializeField] private float nextFire;
    [SerializeField] public bool isGunSilenced;
    [SerializeField] public Transform gunEnd;

    void Start ()
    {
		if(isGunSilenced)
        {
            damage = damage * 0.75f;
        }
	}

	void Update ()
    {
        if (Input.GetButtonDown("Fire1") && Time.time > nextFire)
        {
            nextFire = Time.time + fireRate;

            RaycastHit hit;

            if (Physics.Raycast(gunEnd.transform.position, gunEnd.transform.forward, out hit, 10.0f))
            {
                Enemy enemy = hit.collider.GetComponent<Enemy>();

                if(enemy != null)
                {
                    enemy.EnemyHit();
                }
            }
        }
    }
}
