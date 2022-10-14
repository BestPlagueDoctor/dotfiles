final: prev: {
  hyprland = prev.hyprland.override { nvidiaPatches = true; };

  cryptsetup = prev.cryptsetup.overrideAttrs (_: {
    doCheck = false;
  });

  girara = prev.girara.overrideAttrs (_: {
    doCheck = false;
  });

  mathematica = prev.mathematica.overrideAttrs (_: {
    postInstall = ''
      ln -s "$out/libexec/Mathematica/Executables/wolframscript" "$out/bin/wolframscript"
    '';
  });
}
