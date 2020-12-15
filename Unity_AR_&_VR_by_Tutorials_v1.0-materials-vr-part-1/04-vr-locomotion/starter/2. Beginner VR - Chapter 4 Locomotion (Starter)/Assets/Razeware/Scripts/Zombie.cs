using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Zombie : Enemy
{
	void Start ()
    {
        health = 150;
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

        Debug.Log("Hit a zombie");
    }
}
