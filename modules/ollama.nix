{ pkgs, lib, ... }:

let
  models = [
    "qwen2.5-coder:7b"
  ];
in
{
  home.packages = [
    pkgs.ollama
  ];

  systemd.user.services.ollama = lib.mkIf pkgs.stdenv.isLinux {
    Unit = {
      Description = "Ollama";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };

    Service = {
      ExecStart = "${pkgs.ollama}/bin/ollama serve";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install.WantedBy = [ "default.target" ];
  };

  launchd.agents.ollama = lib.mkIf pkgs.stdenv.isDarwin {
    enable = true;

    config = {
      ProgramArguments = [
        "${pkgs.ollama}/bin/ollama"
        "serve"
      ];

      RunAtLoad = true;
      KeepAlive = true;
    };
  };

  home.activation.installOllamaModels = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${lib.concatMapStringsSep "\n" (model: ''
      echo "Installing Ollama model: ${model}"
      ${pkgs.ollama}/bin/ollama pull "${model}"
    '') models}
  '';
}

