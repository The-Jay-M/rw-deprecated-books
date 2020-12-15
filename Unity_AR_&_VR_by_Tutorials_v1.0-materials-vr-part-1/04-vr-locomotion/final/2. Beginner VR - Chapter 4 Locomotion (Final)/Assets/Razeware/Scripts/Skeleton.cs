using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Skeleton : Enemy
{
	void Start ()
    {
        health = 60;
	}
	
	void Update ()
    {
		
	}

    public void OnTriggerEnter(Collider other)
    {

    }

    public override void EnemyHit()
    {
        base.EnemyHit();


    }
}
