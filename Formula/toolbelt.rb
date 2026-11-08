# typed: strict
# frozen_string_literal: true

# Installs toolbelt, ratchet and plumbob at one release version, with the
# installing organization's configuration: its supply endpoint, execution
# provider and declared sets. The archives come from the public releases
# repository; the configuration is only in this tap. The archives are not
# signed: the SHA-256 below verifies their bytes, not who published them.
class Toolbelt < Formula
  desc "Requirements, supply and execution for a component's own build"
  homepage "https://github.com/ConnectedLabs/toolbelt"
  version "0.1.0-rc.1"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/ConnectedLabs/toolbelt/releases/download/toolbelt-v0.1.0-rc.1/toolbelt-0.1.0-rc.1-darwin-arm64.tar.gz"
      sha256 "c2e6635406cd609b7106e752a3e91c9ac3544ddbdfe4a254a0454c20b3220ad7"
    else
      url "https://github.com/ConnectedLabs/toolbelt/releases/download/toolbelt-v0.1.0-rc.1/toolbelt-0.1.0-rc.1-darwin-amd64.tar.gz"
      sha256 "fba94999a815f66808589e3e7b8aa9c7d0f00da0f928dd5601b6bc3e01e13eac"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/ConnectedLabs/toolbelt/releases/download/toolbelt-v0.1.0-rc.1/toolbelt-0.1.0-rc.1-linux-arm64.tar.gz"
      sha256 "9281c4ccbbedb694eecd65b9e7b47a37de4a7a6f124cb08fe711daeb4f275fb7"
    else
      url "https://github.com/ConnectedLabs/toolbelt/releases/download/toolbelt-v0.1.0-rc.1/toolbelt-0.1.0-rc.1-linux-amd64.tar.gz"
      sha256 "f18286b34465ab709b2dfa26bfd41eff9b7c61afd0d71758cdc1df8b954bd4a0"
    end
  end

  def install
    bin.install "toolbelt", "ratchet", "plumbob"
    pkgshare.install "PROVENANCE.json"
    (pkgshare/"config.json").write <<~JSON
      {
        "endpoint": "https://artifacts.pong.ai/repository/raw-dev/build-supply/",
        "provider_repository": "ConnectedLabs/internal-sdlc-tooling",
        "provider_ref": "feat/toolbelt",
        "operator": "ConnectedLabs"
      }
    JSON
    (pkgshare/"sets").mkpath
    (pkgshare/"sets/pong.yaml").write <<~YAML
      # set.v1: the repositories that work together in the Pong project.
      # Members are named by repository; toolbelt survey --set finds local clones
      # by their remote (--checkouts), never by path.
      contract: set.v1
      name: pong
      owner: ConnectedLabs
      members:
        # The application monorepo
        - ConnectedLabs/pong_legacy
        # Platform operations: runtime images, infrastructure, delivery
        - sovnedge/se-platform-ops
        - sovnedge/se-platform-services
        - sovnedge/se-platform-surfaces
        - sovnedge/sovnctl
        # SDLC tooling: toolbelt and its compilation, CI platform
        - ConnectedLabs/internal-sdlc-tooling
        - ConnectedLabs/ci-platform-core
        # PongLabs originals still outside pong_legacy
        - PongLabs/ponglabs_broker
        - PongLabs/PongWebsite
        - PongLabs/ponglabs-openai_gw
        - PongLabs/pong_svc_orca
        - PongLabs/structured-communication-platform
        - PongLabs/pong-product-web-client
        # Runtime platforms
        - ConnectedLabs/sovn-run-platform
        - ConnectedLabs/network-runtime
        - ConnectedLabs/tailmesh-platform
    YAML
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/toolbelt version").strip
    assert_equal version.to_s, shell_output("#{bin}/ratchet version").strip
    assert_equal version.to_s, shell_output("#{bin}/plumbob version").strip
    assert_match "usage: toolbelt run", shell_output("#{bin}/toolbelt run --help 2>&1")
  end
end
