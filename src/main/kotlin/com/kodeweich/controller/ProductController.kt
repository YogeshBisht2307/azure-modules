package com.kodeweich.controller

import com.kodeweich.SampleInputMessage
import com.kodeweich.SampleReturnMessage
import io.micronaut.http.annotation.Controller
import io.micronaut.http.annotation.Get
import io.micronaut.http.annotation.Post
import io.micronaut.http.annotation.Body
import io.micronaut.http.annotation.Produces
import io.micronaut.http.MediaType

@Controller("/products")
class ProductController {

    @Produces(MediaType.TEXT_PLAIN)
    @Get
    fun index(): String {
        return "Example Response Products"
    }

    @Post
    fun post(@Body inputMessage: SampleInputMessage): SampleReturnMessage {
        return SampleReturnMessage("Hello ${inputMessage.name}, thank you for sending the message")
    }
}