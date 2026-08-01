package com.marivaldojunior.critsense.crit_sense

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlin.math.sqrt

/**
 * Ponto de entrada da Activity Android do CritSense.
 *
 * Além de hospedar o Flutter Engine, esta Activity implementa [SensorEventListener]
 * para receber leituras do acelerômetro diretamente do [SensorManager] — sem
 * depender de bibliotecas de terceiros — e expõe dois canais de comunicação
 * com o Dart: um [MethodChannel] para feedback pontual e um [EventChannel]
 * para streaming contínuo de eventos de shake.
 */
class MainActivity : FlutterActivity(), SensorEventListener {

    private companion object {
        // Nomes idênticos aos registrados em HardwareBridge.dart — qualquer
        // divergência resulta em MissingPluginException silencioso no Flutter.
        const val METHOD_CHANNEL = "com.marivaldojunior.critsense/feedback"
        const val EVENT_CHANNEL  = "com.marivaldojunior.critsense/sensor"

        // 2.2g captura gestos enérgicos de shake sem falsos positivos
        // por movimentos cotidianos (andar, tirar o celular do bolso).
        const val SHAKE_THRESHOLD_G = 2.2f

        // Janela de debounce: um único gesto físico gera ~50 leituras consecutivas
        // em SENSOR_DELAY_GAME; 1 segundo garante exatamente um evento por shake.
        const val SHAKE_DEBOUNCE_MS = 1_000L
    }

    private var sensorManager: SensorManager? = null
    private var accelerometer: Sensor? = null

    // EventSink é o "lado de escrita" do canal de stream —
    // só existe enquanto o Flutter estiver com listen() ativo.
    private var eventSink: EventChannel.EventSink? = null

    private var lastShakeTimestamp = 0L

    // ─── Configuração dos Canais ───────────────────────────────────────────────

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        setupMethodChannel(flutterEngine)
        setupEventChannel(flutterEngine)
    }

    /**
     * Registra o [MethodChannel] para chamadas únicas de feedback sensorial.
     *
     * O MethodChannel funciona como RPC: o Flutter invoca um método por nome
     * e o nativo responde via [MethodChannel.Result]. Cada chamada é independente
     * e efêmera — sem conexão persistente, ao contrário do [EventChannel].
     *
     * [result.notImplemented] sinaliza ao Flutter que o método não existe no
     * nativo, permitindo que o lado Dart lance [MissingPluginException] de forma
     * controlada em vez de travar silenciosamente.
     */
    private fun setupMethodChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "criticalSuccess" -> {
                        vibrateCriticalSuccess()
                        result.success(null)
                    }
                    "criticalFailure" -> {
                        vibrateCriticalFailure()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * Registra o [EventChannel] e conecta o [SensorManager] ao [SensorEventListener].
     *
     * O padrão Observer está em ação aqui: esta Activity é o Observer; o
     * [SensorManager] é o Subject. O Flutter, por sua vez, é um segundo Observer
     * que assiste ao [EventChannel] — formando uma cadeia de observação:
     * Hardware → SensorManager → MainActivity → EventSink → Flutter Stream.
     *
     * O acelerômetro é nulo em dispositivos sem o sensor (tablets de baixo custo,
     * emuladores). O operador `?.` do Kotlin evita NPE nesses casos — o canal
     * simplesmente nunca emitirá eventos, sem crashar o app.
     */
    private fun setupEventChannel(flutterEngine: FlutterEngine) {
        sensorManager  = getSystemService(Context.SENSOR_SERVICE) as? SensorManager
        accelerometer  = sensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {

                /**
                 * Invocado quando o Flutter executa `stream.listen()`.
                 * Registra este [SensorEventListener] para iniciar o recebimento
                 * de dados do acelerômetro a partir deste momento.
                 */
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    eventSink = events
                    // SENSOR_DELAY_GAME (~50 Hz) equilibra responsividade e consumo
                    // de bateria; FASTEST (~200 Hz) seria excessivo para detecção de shake.
                    sensorManager?.registerListener(
                        this@MainActivity,
                        accelerometer,
                        SensorManager.SENSOR_DELAY_GAME,
                    )
                }

                /**
                 * Invocado quando o Flutter cancela a [StreamSubscription].
                 * Remove o listener para interromper o consumo de CPU/bateria.
                 */
                override fun onCancel(arguments: Any?) {
                    sensorManager?.unregisterListener(this@MainActivity)
                    eventSink = null
                }
            })
    }

    // ─── SensorEventListener ──────────────────────────────────────────────────

    /**
     * Recebe leituras brutas do acelerômetro a cada ciclo do sensor.
     *
     * Implementa o método de notificação do padrão Observer: o [SensorManager]
     * (Subject) chama este método (Observer.update) a cada nova leitura,
     * passando os dados via [SensorEvent] — equivalente ao `onNext(T)` do Rx/C#.
     *
     * @param event Leitura bruta com aceleração em m/s² nos eixos X, Y e Z.
     */
    override fun onSensorChanged(event: SensorEvent) {
        if (event.sensor.type != Sensor.TYPE_ACCELEROMETER) return

        val x = event.values[0]
        val y = event.values[1]
        val z = event.values[2]

        // Magnitude do vetor de aceleração dividida pela gravidade terrestre
        // (9.80665 m/s²) converte m/s² → g-force: unidade adimensional e
        // portável entre dispositivos com diferentes calibrações de sensor.
        val gForce = sqrt(x * x + y * y + z * z) / SensorManager.GRAVITY_EARTH

        if (gForce < SHAKE_THRESHOLD_G) return

        val now = System.currentTimeMillis()

        // Debounce: um movimento físico único gera dezenas de leituras consecutivas
        // acima do limiar. Sem esta janela de tempo, o Flutter receberia uma rajada
        // de eventos por shake — tornando a experiência incontrolável.
        if (now - lastShakeTimestamp < SHAKE_DEBOUNCE_MS) return
        lastShakeTimestamp = now

        // `?.success` usa chamada segura: não envia se o Flutter não estiver
        // mais escutando (entre onCancel e uma eventual reinscricão).
        eventSink?.success("SHAKE_DETECTED")
    }

    /** Não reagimos a mudanças de precisão do acelerômetro neste contexto. */
    override fun onAccuracyChanged(sensor: Sensor, accuracy: Int) = Unit

    // ─── Vibração ─────────────────────────────────────────────────────────────

    /**
     * Obtém o [Vibrator] correto para a versão do Android em execução.
     *
     * [VibratorManager] (API 31+) é a API moderna, que suporta controle
     * granular de amplitude e múltiplos motores. O [Vibrator] legado é
     * mantido para retrocompatibilidade com Android 5 (API 21+).
     *
     * O `?.` garante null-safety: dispositivos sem motor de vibração
     * (alguns tablets) retornam null e os métodos de vibração simplesmente
     * não fazem nada — sem crash.
     */
    private fun getVibrator(): Vibrator? =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            (getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager)
                ?.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
        }

    /**
     * Aciona vibração de **acerto crítico**: dois pulsos curtos e crescentes.
     *
     * O padrão rítmico (fraco → forte) comunica celebração pelo tato,
     * sem que o jogador precise olhar para a tela durante a mesa de jogo.
     *
     * [VibrationEffect.createWaveform] (API 26+) permite controle de amplitude
     * por segmento. Em APIs anteriores, cai para o padrão legado sem amplitudes.
     */
    private fun vibrateCriticalSuccess() {
        val timings   = longArrayOf(0, 80, 60, 80) // delay, vibra, pausa, vibra
        val amplitudes = intArrayOf(0, 180, 0, 255) // silêncio, médio, silêncio, máximo

        val vibrator = getVibrator() ?: return

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator.vibrate(VibrationEffect.createWaveform(timings, amplitudes, -1))
        } else {
            @Suppress("DEPRECATION")
            vibrator.vibrate(timings, -1)
        }
    }

    /**
     * Aciona vibração de **falha crítica**: uma vibração única, longa e máxima.
     *
     * O padrão contínuo (oposto ao rítmico do sucesso) é instintivamente
     * associado a algo errado — princípio de UX háptica de contraste semântico.
     */
    private fun vibrateCriticalFailure() {
        val timings    = longArrayOf(0, 500) // delay, vibra longa
        val amplitudes = intArrayOf(0, 255)  // silêncio, amplitude máxima

        val vibrator = getVibrator() ?: return

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator.vibrate(VibrationEffect.createWaveform(timings, amplitudes, -1))
        } else {
            @Suppress("DEPRECATION")
            vibrator.vibrate(timings, -1)
        }
    }

    // ─── Ciclo de Vida ────────────────────────────────────────────────────────

    /**
     * Garante a remoção do listener mesmo que [EventChannel.StreamHandler.onCancel]
     * não seja chamado — por exemplo, se o processo for encerrado pelo sistema.
     * Sem isso, o SensorManager manteria referência à Activity destruída,
     * causando vazamento de memória e consumo silencioso de CPU.
     */
    override fun onDestroy() {
        sensorManager?.unregisterListener(this)
        super.onDestroy()
    }
}

