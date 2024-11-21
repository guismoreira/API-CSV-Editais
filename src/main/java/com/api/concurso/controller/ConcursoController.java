package com.api.concurso.controller;

import org.python.util.PythonInterpreter;
import org.springframework.core.io.FileSystemResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;

@RestController
@RequestMapping("/api")
public class ConcursoController {

    @GetMapping("/csv")
    public ResponseEntity<FileSystemResource> generateCsv() {
        String basePath = new File("").getAbsolutePath();
        String scriptPath = basePath + "/src/main/resources/py/PCI.py";
        String outputCsvPath = basePath + "/ConcursosAtivos.csv";

        try {
            // Verifica se está em ambiente local (exemplo usando uma variável de ambiente)
            String env = System.getenv("ENVIRONMENT");
            boolean isLocal = (env == null || env.equalsIgnoreCase("local"));

            if (isLocal) {
                System.out.println("Executando em ambiente local. Instalando dependências...");
                ProcessBuilder installBuilder = new ProcessBuilder(
                        "python", "-m", "pip", "install", "--upgrade", "pip",
                        "requests", "beautifulsoup4", "pandas");
                installBuilder.redirectErrorStream(true);
                Process installProcess = installBuilder.start();

                try (BufferedReader reader = new BufferedReader(
                        new InputStreamReader(installProcess.getInputStream()))) {
                    String line;
                    while ((line = reader.readLine()) != null) {
                        System.out.println("Instalação de dependências: " + line);
                    }
                }

                int installExitCode = installProcess.waitFor();
                if (installExitCode != 0) {
                    return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                            .body(null);
                }
            }
            if (!isLocal) {
                scriptPath = "my-project/src/main/resources/py/PCI.py";
            }

            // Executa o script Python
            System.out.println("Executando o script Python...");
            ProcessBuilder processBuilder = new ProcessBuilder("python", scriptPath);
            processBuilder.redirectErrorStream(true);
            Process process = processBuilder.start();

            try (BufferedReader reader = new BufferedReader(
                    new InputStreamReader(process.getInputStream()))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    System.out.println("Geração de CSV: " + line);
                }
            }

            int exitCode = process.waitFor();
            if (exitCode != 0) {
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                        .body(null);
            }

            // Verifica se o arquivo foi gerado
            File outputFile = new File(outputCsvPath);
            if (!outputFile.exists()) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
            }

            FileSystemResource resource = new FileSystemResource(outputFile);
            HttpHeaders headers = new HttpHeaders();
            headers.add(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=" + outputFile.getName());
            headers.add(HttpHeaders.CONTENT_TYPE, "text/csv");

            return ResponseEntity.ok()
                    .headers(headers)
                    .body(resource);

        } catch (IOException | InterruptedException e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(null);
        }
    }

}