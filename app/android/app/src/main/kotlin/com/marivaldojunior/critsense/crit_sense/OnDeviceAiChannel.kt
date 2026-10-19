package com.marivaldojunior.critsense.crit_sense

import com.google.mlkit.genai.common.DownloadStatus
import com.google.mlkit.genai.common.FeatureStatus
import com.google.mlkit.genai.prompt.Generation
import com.google.mlkit.genai.prompt.GenerativeModel
import com.google.mlkit.genai.prompt.TextPart
import com.google.mlkit.genai.prompt.generateContentRequest
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

/**
 * Canal da IA no aparelho (Gemini Nano pelo ML Kit GenAI Prompt API).
 *
 * Métodos, com o mesmo nome em `on_device_ai.dart`:
 * - `status`: "available", "downloadable", "downloading" ou "unavailable".
 * - `download`: baixa o modelo e devolve `true` quando ele fica pronto.
 * - `generate`: recebe `prompt`, `temperature` e `maxOutputTokens` e
 *   devolve o texto gerado.
 *
 * O texto da ficha nunca sai do aparelho: o modelo roda no AICore do
 * Android.
 */
class OnDeviceAiChannel : MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL = "com.marivaldojunior.critsense/genai"
    }

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)

    // Criado só no primeiro uso: em aparelhos sem o AICore, o app não paga
    // nada por ter o canal.
    private var model: GenerativeModel? = null

    private fun client(): GenerativeModel =
        model ?: Generation.getClient().also { model = it }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "status" -> scope.launch {
                try {
                    result.success(statusName(client().checkStatus()))
                } catch (e: Exception) {
                    result.success("unavailable")
                }
            }
            "download" -> scope.launch {
                try {
                    var completed = false
                    client().download().collect { status ->
                        when (status) {
                            is DownloadStatus.DownloadCompleted -> completed = true
                            is DownloadStatus.DownloadFailed -> completed = false
                            else -> Unit
                        }
                    }
                    result.success(completed)
                } catch (e: Exception) {
                    result.error("download_failed", e.message, null)
                }
            }
            "generate" -> {
                val prompt = call.argument<String>("prompt")
                if (prompt.isNullOrBlank()) {
                    result.error("bad_args", "O prompt está vazio.", null)
                    return
                }
                val temp = (call.argument<Double>("temperature") ?: 0.1).toFloat()
                val maxTokens = call.argument<Int>("maxOutputTokens") ?: 256
                scope.launch {
                    try {
                        val response = client().generateContent(
                            generateContentRequest(TextPart(prompt)) {
                                temperature = temp
                                topK = 10
                                maxOutputTokens = maxTokens
                            },
                        )
                        result.success(response.candidates.firstOrNull()?.text)
                    } catch (e: Exception) {
                        result.error("generate_failed", e.message, null)
                    }
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun statusName(status: Int): String = when (status) {
        FeatureStatus.AVAILABLE -> "available"
        FeatureStatus.DOWNLOADABLE -> "downloadable"
        FeatureStatus.DOWNLOADING -> "downloading"
        else -> "unavailable"
    }

    /** Fecha o modelo e cancela as chamadas em andamento. */
    fun dispose() {
        scope.cancel()
        model?.close()
        model = null
    }
}
