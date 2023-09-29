# Natter

***WORK IN PROGRESS*

Overview:

This system combines two secure communication tools into one package: a mechanism to exchange encrypted messages and files through an intermediary Azure instance (termed as the "Distributed Digital Dead Drop"), and a platform to set up or join a live chat, including an ultra-secure method over the Tor network using OnionShare.

The primary feature, the "Distributed Digital Dead Drop", allows for encrypted communication between two users (user-1 and user-2). To further enhance security, public keys are exchanged between users prior to any encrypted communication.

Meanwhile, the secondary feature provides users with the option to have a live chat either over a standard network or more securely over the Tor network.
Features:

    Secure File Transfer: Enables users to send files securely to a chosen Azure instance using SCP.

    Encrypted Messaging: Users can exchange encrypted messages. Encryption is managed using the recipient's public key.

    Public Key Exchange: Essential for initiating messaging, this feature ensures that messages are encrypted in a way that only the designated recipient can decrypt.

    Azure Instance Selection: Provides flexibility by allowing users to either select an Azure instance at random or choose one from a list. Crucially, for successful communication, both users should select the same instance.

    Automated Message Receipt Check: Designed for convenience, the script periodically checks for the arrival of a new encrypted message on the Azure instance.

    Live Chat Setup: Users have the option to set up a live chat session. The tool provides guidelines on connecting to existing networks or creating new ones.

    Tor Chat via OnionShare: This feature offers the highest level of security. Once Tor is fully connected, users can chat securely over the Tor network using OnionShare.

Usage:

    For Distributed Digital Dead Drop:
        Start the script.
        Choose the mode: Either initiate the dead drop or exit.
        Determine your user role (either user-1 or user-2).
        Establish an SSH connection to an Azure instance. Users can either select an instance at random or choose one from a given list.
        Exchange public keys.
        After exchanging keys, users can send or receive encrypted messages or securely transfer files.

    For Live Chat:
        Run the script.
        Decide on the chat mode: Connect and chat on a live server, chat over Tor, or go back.
        If the first mode is selected, users are guided to either connect to an existing network or create a new one. They are also given instructions for initiating chats.
        For the second mode, the OnionShare chat room is initiated after ensuring Tor connectivity.

Prerequisites:

    Ensure you have openssl, scp, and onionshare-cli installed on your system.
    The script relies on a file named login_info.csv containing IP addresses and corresponding private key filenames for Azure instances.
