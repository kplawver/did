import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    challengeUrl: String,
    registrationUrl: String,
    redirectUrl: String
  }

  async register() {
    try {
      const response = await fetch(this.challengeUrlValue || this.registrationUrlValue.replace(/\/?$/, '/new'), {
        method: "GET",
        headers: {
          "Accept": "application/json",
          "X-CSRF-Token": this.csrfToken
        }
      })
      const options = await response.json()

      options.challenge = this.base64urlToBuffer(options.challenge)
      options.user.id = this.base64urlToBuffer(options.user.id)
      if (options.excludeCredentials) {
        options.excludeCredentials = options.excludeCredentials.map(cred => ({
          ...cred,
          id: this.base64urlToBuffer(cred.id)
        }))
      }

      const credential = await navigator.credentials.create({ publicKey: options })

      const nickname = prompt("Give this passkey a name:", "My Passkey")

      const createResponse = await fetch(this.registrationUrlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-CSRF-Token": this.csrfToken
        },
        body: JSON.stringify({
          credential: this.serializeCredential(credential),
          nickname: nickname
        })
      })

      if (createResponse.ok) {
        if (this.hasRedirectUrlValue) {
          window.location.href = this.redirectUrlValue
        } else {
          window.location.reload()
        }
      } else {
        const error = await createResponse.json()
        alert(`Failed to register passkey: ${error.error}`)
      }
    } catch (error) {
      if (error.name !== "NotAllowedError") {
        console.error("Passkey registration failed:", error)
        alert("Passkey registration failed. Please try again.")
      }
    }
  }

  async authenticate() {
    try {
      const response = await fetch(this.challengeUrlValue, {
        method: "GET",
        headers: {
          "Accept": "application/json",
          "X-CSRF-Token": this.csrfToken
        }
      })
      const options = await response.json()

      options.challenge = this.base64urlToBuffer(options.challenge)
      if (options.allowCredentials) {
        options.allowCredentials = options.allowCredentials.map(cred => ({
          ...cred,
          id: this.base64urlToBuffer(cred.id)
        }))
      }

      const credential = await navigator.credentials.get({ publicKey: options })

      const authResponse = await fetch("/users/passkey_authentication", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-CSRF-Token": this.csrfToken
        },
        body: JSON.stringify({
          credential: this.serializeCredential(credential)
        })
      })

      if (authResponse.ok) {
        const data = await authResponse.json()
        window.location.href = data.redirect_to || "/"
      } else {
        const error = await authResponse.json()
        alert(`Authentication failed: ${error.error}`)
      }
    } catch (error) {
      if (error.name !== "NotAllowedError") {
        console.error("Passkey authentication failed:", error)
        alert("Passkey authentication failed. Please try again.")
      }
    }
  }

  get csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content
  }

  base64urlToBuffer(base64url) {
    const base64 = base64url.replace(/-/g, "+").replace(/_/g, "/")
    const padded = base64 + "=".repeat((4 - base64.length % 4) % 4)
    const binary = atob(padded)
    return Uint8Array.from(binary, c => c.charCodeAt(0)).buffer
  }

  bufferToBase64url(buffer) {
    const bytes = new Uint8Array(buffer)
    let binary = ""
    for (const byte of bytes) {
      binary += String.fromCharCode(byte)
    }
    return btoa(binary).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "")
  }

  serializeCredential(credential) {
    const response = credential.response
    const serialized = {
      id: credential.id,
      rawId: this.bufferToBase64url(credential.rawId),
      type: credential.type,
      response: {
        clientDataJSON: this.bufferToBase64url(response.clientDataJSON)
      }
    }

    if (response.attestationObject) {
      serialized.response.attestationObject = this.bufferToBase64url(response.attestationObject)
    }

    if (response.authenticatorData) {
      serialized.response.authenticatorData = this.bufferToBase64url(response.authenticatorData)
    }

    if (response.signature) {
      serialized.response.signature = this.bufferToBase64url(response.signature)
    }

    if (response.userHandle) {
      serialized.response.userHandle = this.bufferToBase64url(response.userHandle)
    }

    return serialized
  }
}
