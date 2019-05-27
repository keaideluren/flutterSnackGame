package com.luren.myfirstflutter

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.widget.TextView

/**
 * Created by 拇指 on 2019/5/10 0010.
 * Email:muzhi@uoko.com
 * TODO
 */
class SplashActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val tv = TextView(this)
        setContentView(tv)
        tv.text = "点击"
        tv.setOnClickListener { startActivity(Intent(this@SplashActivity, MainActivity::class.java)) }
    }
}