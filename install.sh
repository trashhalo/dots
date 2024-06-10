if ! command -v just &> /dev/null
then
    echo "just command not found, installing..."
    git clone https://mpr.makedeb.org/just
    pushd just
    makedeb -si
    sudo dpkg -i just_*_amd64.deb
    popd
else
    echo "just command found, skipping installation"
fi

just install