package com.kodeweich
import com.microsoft.azure.functions.*
import com.microsoft.azure.functions.annotation.*
import io.micronaut.azure.function.http.AzureHttpFunction
import java.util.*

class Function : AzureHttpFunction() {
    @FunctionName("HTTPRequestHandler")
    fun invoke(
        @HttpTrigger(name = "req",
            methods = [HttpMethod.GET, HttpMethod.POST],
            route = "{*route}",
            authLevel = AuthorizationLevel.ANONYMOUS)
        request: HttpRequestMessage<Optional<String>>,
        context: ExecutionContext): HttpResponseMessage {
        println("Path:- ${request.uri}")
        return super.route(request, context)
    }
}
