#!/bin/sh

swiftgen colors --templatePath "templates/colors.stencil" --param enumName=MTColor --output "../leadsbooster/Global/Colors.swift" ../leadsbooster/Resources/Colors.xcassets
