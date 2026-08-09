{ pkgs, lib, ... }:

let
  agents = [
    "qwen2.5-coder:7b"
  ];

  installAgents = pkgs.writeShellScript "install-ollama-agents" ''
    set -eu

    ${lib.concatMapStringsSep "\n" (agent: ''
      echo "Installing Ollama agent: ${agent}"
      ${pkgs.ollama}/bin/ollama pull "${agent}"
    '') agents}
  '';
in
{
  services.ollama = {
    enable = true;
    package = pkgs.ollama;
  };

  home.packages = [
    pkgs.ollama
  ];

  home.activation.installOllamaAgents = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${installAgents}
  '';
}

